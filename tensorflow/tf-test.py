import os

# Check that TF imports correctly (there could be error messages)
import tensorflow as tf

print('TF imported.')
print("TF version:", tf.__version__)

# Check that tf-text imports correctly
try:
    import tensorflow_text
    print('TF-text imported.')
except ImportError as e:
    print(e)
    print('WARNING: TF-text could not be imported.')

# Check that cuDNN is linked correctly and works
inputs = tf.random.normal([32, 10, 8])
lstm = tf.keras.layers.LSTM(4)
output = lstm(inputs)

print('LSTM cuDNN test completed.')

# Check if MKL is enabled

def get_mkl_enabled_flag():
    mkl_enabled = False
    major_version = int(tf.__version__.split(".")[0])
    minor_version = int(tf.__version__.split(".")[1])
    if major_version >= 2:
        if minor_version < 5:
            from tensorflow.python import _pywrap_util_port
        else:
            from tensorflow.python.util import _pywrap_util_port
            onednn_enabled = int(os.environ.get('TF_ENABLE_ONEDNN_OPTS', '0'))
        mkl_enabled = _pywrap_util_port.IsMklEnabled() or (onednn_enabled == 1)
    else:
        mkl_enabled = tf.pywrap_tensorflow.IsMklEnabled()
    return mkl_enabled

is_ok = True
if get_mkl_enabled_flag():
    is_ok = False
    print('ERROR: MKL is enabled. MKL could cause problems on Narval\'s AMD CPUs.')
else:
    print('MKL is disabled, which is ok.')

gpus = tf.config.list_physical_devices('GPU')
if len(gpus) == 0:
    print('WARNING: No GPU found. Please make sure to run this on a GPU node.')

print('==========')
print('TF test completed. Please check for errors or warnings above.')

exit(0 if is_ok else 1)

