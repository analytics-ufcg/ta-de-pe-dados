import shutil

try:
    shutil.rmtree('/data/tce_rs/empenhos')
except OSError as e:
    print(e)
else:
    print("The directory is deleted successfully")