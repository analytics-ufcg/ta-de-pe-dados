import os, shutil

folder = '/data/tce_rs/empenhos'

for the_file in os.listdir(folder):

    try:
        shutil.rmtree('/data/tce_rs/empenhos/' + the_file)
    except Exception as e:
        print(e)

