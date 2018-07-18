!IF "$(PLATFORM)"=="X64" || "$(PLATFORM)"=="x64"
ARCH=amd64
!ELSE
ARCH=x86
!ENDIF

OUTDIR=bin\$(ARCH)
OBJDIR=obj\$(ARCH)
SRCDIR=PPLKiller
TARGETNAME=pplkiller.sys

WDKINCPATH=C:\Program Files (x86)\Windows Kits\10\Include\10.0.17134.0\km
WDKLIBPATH=C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17134.0\km\$(PLATFORM)
CODESIGN_SHA1=34961b53b61d2de7bc31da0fa5ebb78417c6c280

CC=cl
LINKER=link
SIGNTOOL=signtool
RD=rd/s/q
RM=del/q

OBJS=\
	$(OBJDIR)\main.obj\

LIBS=\
	bufferoverflowfastfailk.lib\
	ntoskrnl.lib\

CFLAGS=\
	/nologo\
	/c\
	/kernel\
	/std:c++latest\
	/Zi\
	/Od\
	/W4\
	/Fo"$(OBJDIR)\\"\
	/Fd"$(OBJDIR)\\"\
	/I"$(WDKINCPATH)"\
	/I"$(WDKINCPATH)\crt"\
!IF "$(ARCH)"=="amd64"
	/D_AMD64_\
!ELSE
	/D_X86_\
!ENDIF
	/GF\
	/Gm-\
	/GS\
	/Gy\
	/Gz\
	/GR-\

LFLAGS=\
	/NOLOGO\
	/DEBUG\
	/INCREMENTAL:NO\
	/SUBSYSTEM:NATIVE\
	/DRIVER\
	/KERNEL\
	/ENTRY:"DriverEntry"\
	/LIBPATH:"$(WDKLIBPATH)"\

all: $(OUTDIR)\$(TARGETNAME)

$(OUTDIR)\$(TARGETNAME): $(OBJS)
	@if not exist $(OUTDIR) mkdir $(OUTDIR)
	$(LINKER) $(LFLAGS) $(LIBS) /PDB:"$(@R).pdb" /OUT:$@ $**
	$(SIGNTOOL) sign /ph /sha1 $(CODESIGN_SHA1) $@

{$(SRCDIR)}.cpp{$(OBJDIR)}.obj:
	@if not exist $(OBJDIR) mkdir $(OBJDIR)
	$(CC) $(CFLAGS) $<

clean:
	@if exist $(OBJDIR) $(RD) $(OBJDIR)
	@if exist $(OUTDIR)\$(DRIVER) $(RM) $(OUTDIR)\$(DRIVER)
	@if exist $(OUTDIR)\$(DRIVER:sys=pdb) $(RM) $(OUTDIR)\$(DRIVER:sys=pdb)
