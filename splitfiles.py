import sys


def split_files(dest, filename, nf=50):
    the_file = open(dest + '/' + filename + '.txt', 'r')
    lines = the_file.readlines()
    lines = [line.rstrip() for line in lines]
    nf=int(nf)
    for i in range(len(lines)/int(nf)):
        fileout = open(dest + '/' + filename + str(i) + '.txt', 'w')
        st = i * nf
        ed = len(lines) if ((st + nf) > len(lines)) else st + nf
	print st
	print ed
        fileout.writelines(l+'\n' for l in lines[st:ed])


if __name__ == '__main__':
    split_files(sys.argv[1], sys.argv[2], sys.argv[3])
