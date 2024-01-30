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
    parser.add_argument("--files", type=str, required=True,
                        help="CSV files, which will be appended to the amalgamated file.")
    args = parser.parse_args(argv)
    frames = []
    args.files = args.files.split(" ")
    for file in args.files:
        if file == "":
            continue
        df = pd.read_csv(file)
        frames.append(df)
    result = pd.concat(frames)
    randNum=random.randint(0,100000)
    path=os.path.join(args.filepath, "amalgamatedResults"+str(randNum)+".csv")
    while os.path.isfile(path):
        randNum+=1
        path=os.path.join(args.filepath, "amalgamatedResults"+str(randNum)+".csv")

    with open(path, 'w') as f:
        f.write(result.to_csv(index=False))
    
    print(path)

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))