#
#
# Toby Opferman
# 
# Toby's System Helper
#   
#   Copyright (c) 2004
#
#
   
 
TARGET = qv
TARGETDIR = ..\..\..\..\..\..\..\bin

ASM = ml
CPP = cl
RSC = rc.exe
F90 = df.exe
MTL = midl.exe
REBASE = rebase.exe

OBJDIR = .\obj\i386

ASM_PROJ=/coff /c /Fo$(OBJDIR)\\

RES_PROJ=/I "..\..\inc" \
        /D "WIN32" /D "_WINDOWS" /fo$(OBJDIR)\tsyshelp.res

CPP_PROJ=/nologo /MD /W3 /Oxs /Zi \
	/I ".\inc" \
        /D "WIN32" /D "_WINDOWS" \
	/Fr$(OBJDIR)\\ /Fo$(OBJDIR)\\ /Fd$(OBJDIR)\\ /c

LIB32= link.exe 
LIB32_FLAGS = /SUBSYSTEM:WINDOWS /nologo $(LIBS) /out:$(TARGETDIR)\$(TARGET).exe

RESFILE = \
        $(OBJDIR)\tsyshelp.res

OBJS   = \
	$(OBJDIR)\tsyshelp.obj


LIBS = \
       kernel32.lib \
       gdi32.lib \
       user32.lib \
       comctl32.lib \
       shlwapi.lib \
       ADVAPI32.LIB

# This is a comment
$(TARGETDIR)\$(TARGET): $(OBJDIR) $(TARGETDIR) $(OBJS) $(RESFILE)
    $(LIB32) $(LIB32_FLAGS) $(OBJS) $(LIBS) $(RESFILE)
#    $(REBASE) -b 0x00100000 -x $(TARGETDIR) -a $(TARGETDIR)\$(TARGET)

{.\}.c{$(OBJDIR)}.obj::
	$(CPP) $(CPP_PROJ) $<

{.\}.cpp{$(OBJDIR)}.obj::
	$(CPP) $(CPP_PROJ) $<


{.\}.asm{$(OBJDIR)}.obj::
	$(ASM) $(ASM_PROJ) $<


{.\}.rc{$(OBJDIR)}.res::
	$(RSC) $(RES_PROJ) $<

$(OBJDIR):
    if not exist "$(OBJDIR)/$(NULL)" mkdir "$(OBJDIR)"

$(TARGETDIR):
    if not exist "$(TARGETDIR)/$(NULL)" mkdir "$(TARGETDIR)"


CLEAN:
	-@erase /S /Q $(OBJDIR)
