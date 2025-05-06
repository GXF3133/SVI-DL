#  System-specific notes

Matlab R2021a

Python 3.6

# How to use it?

Firstly, run SVI_main. m to perform SVI processing in low SNR data.

SVI_main: Code for apply a time window to the low SNR data and perform SVI operation.

Then run train.py to conduct deep learning training.

Lastly, run predict.py to conduct deep learning prediction.

model: Code for building the DL (Deep Learning) model
train_utils: Code for training and validation related tools
dataset.py: Code for reading the dataset
train.py: Code for DL training
predict.py: Code for DL prediction
compute_mean_std.py: Code for calculating the mean and standard deviation of each channel of the dataset

#  REFERENCE

If you have any question, you can contact me via email [gaoxf2024@163.com]