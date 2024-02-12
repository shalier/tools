import sys
import argparse
import pandas as pd
import os
import random

def main(argv):
    parser = argparse.ArgumentParser(
        "Istio performance benchmark put all csv files into one.")
    parser.add_argument(
        "-c", "--filepath", type=str, required=True,
        help="CSV file path, where all csv files will be put into.")
    parser.add_argument("--dirs", type=str, required=True,
                        help="CSV dirs, which will be appended to the amalgamated file.")
    args = parser.parse_args(argv)
    
    frames = []
    dirs= args.dirs.split(" ")
    for file in dirs:
        if file == "":
            continue
        df = pd.read_csv(file)
        frames.append(df)

    df = pd.concat(frames)
    df=df.loc[~df['cpu_mili_avg_istio_proxy_fortioclient'].eq(0)]
    randNum=random.randint(0,100000) # so you don't override files
    path=os.path.join(args.filepath, "amalgamatedResults"+str(randNum)+".csv")
    while os.path.isfile(path):
        randNum+=1
        path=os.path.join(args.filepath, "amalgamatedResults"+str(randNum)+".csv")

    with open(path, 'w') as f:
        f.write(df.to_csv(index=False))
    
    print(path)
    
if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))