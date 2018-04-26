import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
import numpy as np
from skimage.io import imsave
import os
import shutil
import time
import linecache
from tensorflow.contrib import losses
import math
#33*20，20*10，10*1，1*10，10*20，20*33
max_epoch = 50
batch_size = 1
feature_size = 33
mixtures=2
count=30771
def add_noise(mat, stdev=0.001):
    """
    :param mat: should be of shape(k, d, d)
    :param stdev: the standard deviation of noise
    :return: a matrix with little noises
    """
    with tf.name_scope('gaussian_noise'):
        dims = mat.get_shape().as_list()[1]
        noise = stdev + tf.random_normal([dims], 0, stdev * 1e-1)
        noise = tf.diag(noise)
        noise = tf.expand_dims(noise, axis=0)
        noise = tf.tile(noise, (mat.get_shape()[0], 1, 1))
    return mat + noise
class Network:


    def __init__(self,inputs,istraining):
        self.train_model(inputs,istraining)

    def train_model(self,inputs,istraining):
        # self.x_input = tf.placeholder(tf.float32, [batch_size,feature_size],name="x_input")
        self.x_input=inputs
        self.keep_prob = np.sum(0.7).astype(np.float32)
        self.is_training=istraining

        with tf.variable_scope("enc") as enc:
            self.enc1=tf.layers.dense(inputs=self.x_input,units=20,activation=tf.nn.tanh)#33*20
            self.enc2=tf.layers.dense(inputs=self.enc1,units=10,activation=tf.nn.tanh)#20*10
            self.enc3=tf.layers.dense(inputs=self.enc2,units=1,activation=None)#10*1
            self.enc_params=[v for v in tf.global_variables() if v.name.startswith(enc.name)];


        with tf.variable_scope("dec") as dec:
            self.dec1=tf.layers.dense(inputs=self.enc3,units=10,activation=tf.nn.tanh)#1*10
            self.dec2=tf.layers.dense(inputs=self.dec1,units=20,activation=tf.nn.tanh)#10*20
            self.dec3=tf.layers.dense(inputs=self.dec2,units=33,activation=None)#20*33
            self.dec_params=[v for v in tf.global_variables() if v.name.startswith(dec.name)];
            
        self.zc=self.enc3
        self.zr1=tf.sqrt(tf.reduce_sum(tf.square(self.dec3-self.x_input), 1))+1e-12
        self.zr1=tf.reshape(self.zr1,[batch_size,1])
        # self.zr2=tf.reduce_sum(tf.multiply(self.dec3,self.x_input), axis=1)/ (tf.sqrt(tf.reduce_sum(tf.square(self.dec3), axis=1))* tf.sqrt(tf.reduce_sum(tf.square(self.x_input), axis=1)))
        self.zr2=tf.reduce_sum(tf.multiply(tf.nn.l2_normalize(self.dec3,1),tf.nn.l2_normalize(self.x_input,1)),1)
        self.zr2=tf.reshape(self.zr2,[batch_size,1])

        self.zr=tf.concat([self.zr1,self.zr2],1)

        self.z=tf.concat([self.zr,self.zc],1)

        with tf.variable_scope("gmm") as gmm:
            self.gmm1=tf.nn.dropout(tf.layers.dense(inputs=self.z,units=10,activation=tf.nn.tanh),keep_prob=self.keep_prob)
            self.gmm2=tf.layers.dense(inputs=self.gmm1,units=2,activation=None)
            self.gammas=tf.nn.softmax(self.gmm2)
            self.gmm_params=[v for v in tf.global_variables() if v.name.startswith(gmm.name)];

        
        phis = tf.get_variable('phis', shape=[mixtures], initializer=tf.ones_initializer(), dtype=tf.float32, trainable=False)
        mus = tf.get_variable('mus', shape=[mixtures, self.z.get_shape()[1]], initializer=tf.ones_initializer(), dtype=tf.float32, trainable=False)

        init_sigmas = 0.5 * np.expand_dims(np.identity(self.z.get_shape()[1]), axis=0)
        init_sigmas = np.tile(init_sigmas, [mixtures, 1, 1])
        init_sigmas = tf.constant_initializer(init_sigmas)
        sigmas = tf.get_variable('sigmas', shape=[mixtures, self.z.get_shape()[1], self.z.get_shape()[1]], initializer=init_sigmas, dtype=tf.float32, trainable=False)

        sums = tf.reduce_sum(self.gammas, axis=0)
        sums_exp_dims = tf.expand_dims(sums, axis=-1)

        phis_ = sums / batch_size
        mus_ = tf.matmul(self.gammas, self.z, transpose_a=True) / sums_exp_dims
        def assign_training_phis_mus():
            with tf.control_dependencies([phis.assign(phis_), mus.assign(mus_)]):
                return [tf.identity(phis), tf.identity(mus)]

        phis, mus = tf.cond(self.is_training, assign_training_phis_mus, lambda: [phis, mus])

        phis_exp_dims = tf.expand_dims(phis, axis=0)
        phis_exp_dims = tf.expand_dims(phis_exp_dims, axis=-1)
        phis_exp_dims = tf.expand_dims(phis_exp_dims, axis=-1)

        zs_exp_dims = tf.expand_dims(self.z, 1)
        zs_exp_dims = tf.expand_dims(zs_exp_dims, -1)
        mus_exp_dims = tf.expand_dims(mus, 0)
        mus_exp_dims = tf.expand_dims(mus_exp_dims, -1)

        zs_minus_mus = zs_exp_dims - mus_exp_dims

        sigmas_ = tf.matmul(zs_minus_mus, zs_minus_mus, transpose_b=True)
        broadcast_gammas = tf.expand_dims(self.gammas, axis=-1)
        broadcast_gammas = tf.expand_dims(broadcast_gammas, axis=-1)
        sigmas_ = broadcast_gammas * sigmas_
        sigmas_ = tf.reduce_sum(sigmas_, axis=0)
        sigmas_ = sigmas_ / tf.expand_dims(sums_exp_dims, axis=-1)
        sigmas_ = add_noise(sigmas_)

        def assign_training_sigmas():
            with tf.control_dependencies([sigmas.assign(sigmas_)]):
                return tf.identity(sigmas)

        sigmas = tf.cond(self.is_training, assign_training_sigmas, lambda: sigmas)
        with tf.name_scope('loss'):
            loss_reconstruction = tf.reduce_mean(self.zr1)
            inversed_sigmas = tf.expand_dims(tf.matrix_inverse(sigmas), axis=0)
            inversed_sigmas = tf.tile(inversed_sigmas, [tf.shape(zs_minus_mus)[0], 1, 1, 1])
            energy = tf.matmul(zs_minus_mus, inversed_sigmas, transpose_a=True)
            energy = tf.matmul(energy, zs_minus_mus)
            energy = tf.squeeze(phis_exp_dims * tf.exp(-0.5 * energy), axis=[2, 3])
            energy_divided_by = tf.expand_dims(tf.sqrt(2.0 * math.pi * tf.matrix_determinant(sigmas)), axis=0) + 1e-12
            energy = tf.reduce_sum(energy / energy_divided_by, axis=1) + 1e-12
            energy = -1.0 * tf.log(energy)
            energy_mean = tf.reduce_sum(energy) / batch_size
            loss_sigmas_diag = 1.0 / tf.matrix_diag_part(sigmas)
            loss_sigmas_diag = tf.reduce_sum(loss_sigmas_diag)
        self.loss = loss_reconstruction + 0.1 * energy_mean + 0.005 * loss_sigmas_diag
        # self.loss = loss_reconstruction + 0*energy_mean +0*loss_sigmas_diag
        self.test_energy=energy_mean

        self.optimizer = tf.train.AdamOptimizer()

        
        self.trainer = self.optimizer.minimize(self.loss)

        # self.dis_trainer = self.optimizer_dis.minimize(self.d_loss)
        # self.dec_trainer = self.optimizer_dec.minimize(self.d_loss)
        # self.enc_trainer = self.optimizer_enc.minimize(self.rec_loss)
        # tensorboard
        # tf.summary.scalar('dis_loss',tf.reduce_sum(self.d_loss));
        # tf.summary.scalar('gen_loss',tf.reduce_sum(g_loss));
        # tf.summary.scalar('rec_loss',tf.reduce_sum(rec_loss));
        config=tf.ConfigProto(allow_soft_placement=True,log_device_placement=True)
        config.gpu_options.allow_growth = True 
        self.session = tf.Session(config=config)
def main():
     #   if to_train:
    x_input = tf.placeholder(tf.float32, [batch_size, feature_size],name="x_input")
    training=tf.placeholder(tf.bool, shape=None, name='istraining') 
    network = Network(x_input,training)
#    savepath = '/home/mcislab3d/songhao/cvpr2018/model/checkpoint_AAAE_DP07_AD1E4/model.ckpt'
    modelpath = '/media/mcislab3d/795c8875-2ab9-4936-9a4d-91ccc1301997/mcislab3d/songhao/sunche/model/model/'

    savefile1 = '/media/mcislab3d/795c8875-2ab9-4936-9a4d-91ccc1301997/mcislab3d/songhao/sunche/model/scores.txt'

    f1 = open(savefile1,'w')
    f2 = open('gt.txt','w')
    session = network.session
    saver = tf.train.Saver()
    if os.path.exists(modelpath + 'checkpoint'):
        saver.restore(session,modelpath + 'model.ckpt')
        print ('loaded checkpoint')
    else:
        print ('fail to load checkpoint')
    print ('open training file')
    feature_modelpath='/media/mcislab3d/795c8875-2ab9-4936-9a4d-91ccc1301997/mcislab3d/songhao/sunche/model/test.txt'
    with tf.device("/gpu:0"):
        j = 0;
        loss_total = 0
        data_batch=np.zeros((batch_size,feature_size))
        for p in range(count):
            theline_data=linecache.getline(feature_modelpath,p+1);
            theline_data.strip()
            theline_data = theline_data.split('\t')
            data_lst = [float(theline_data[inde]) for inde in range(0,len(theline_data))]
            data_lst = np.array(data_lst)
            data_label=int(data_lst[-1])
            data_lst=data_lst[0:-1]
            data_batch[p%batch_size]=data_lst
            if (p%batch_size==batch_size-1)|(p==count-1):
                _loss_=session.run([network.loss],feed_dict={x_input: data_batch,training:False})
                print ('Rec_Loss:{} '.format(_loss_))
                print (' have test line {} of lines {}'.format(p,count))
                # for item1 in _loss_[0]:
                    # f1.write(' '.join([str(i) for i in item1]))
                # np.savetxt(f1,_loss_)
                f1.write(str(_loss_[0])+'\n')
                f2.write(str(data_label)+'\n')
        linecache.clearcache()
    f1.close()
    f2.close()

if __name__ == '__main__':
    main()