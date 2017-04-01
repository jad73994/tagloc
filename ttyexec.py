import sys,os,fcntl,termios

if len(sys.argv) != 3:
   sys.stderr.write("usage: ttyexec.py tty command\n")
   sys.exit(1)

fd = os.open("/dev/" + sys.argv[1], os.O_RDWR)
cmd=sys.argv[2]
for i in range(len(cmd)):
   fcntl.ioctl(fd, termios.TIOCSTI, cmd[i])
fcntl.ioctl(fd, termios.TIOCSTI, '\n')
os.close(fd)
