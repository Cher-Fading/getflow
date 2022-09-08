import sys


def split_files(dest, filename, nf=50):
    the_file = open(dest + '/' + filename, 'r')
    lines = the_file.readlines()
    lines = [line.rstrip() for line in lines]
    for i in range(len(lines)/nf):
        fileout = open(dest + '/' + filename + str(i) + '.txt', 'w')
        st = i * nf
        ed = len(lines) if ((st + nf) > len(lines)) else st + nf
        fileout.writelines(lines[st:ed])


if __name__ == '__main__':
    split_files(sys.argv[0], sys.argv[1])
