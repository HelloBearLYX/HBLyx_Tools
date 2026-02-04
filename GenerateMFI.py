import os
import shutil

def ExtractFile(source:str, dest:str):
    try:
        shutil.copy(source, dest)
        print(f"{source} copied successfully to {dest}")
    except shutil.SameFileError:
        print("Source and destination represent the same file.")
    except PermissionError:
        print("Permission denied.")
    except IsADirectoryError:
        print("Destination is a directory, but an issue occurred.") # Should not occur with shutil.copy if destination exists
    except FileNotFoundError:
        print("Source file not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

def ExtractFolder(source:str, dest:str, name:str, files:list):
    os.makedirs(os.path.join(dest, name))

    for file in files:
        ExtractFile(source=os.path.join(source, name, file), dest=os.path.join(dest, name))

def CreateMFI():
    # create MFI folder
    FOLDER_NAME = "MidnightFocusInterrupt"
    FOLDER_PATH = os.path.join(os.getcwd(), FOLDER_NAME)

    os.makedirs(FOLDER_PATH)

    # module
    ExtractFolder(source=os.getcwd(), dest=FOLDER_PATH, name="Modules", files=["FocusInterrupt.lua"])
    # config
    ExtractFolder(source=os.getcwd(), dest=FOLDER_PATH, name="Configs", files=["FocusInterrupt.lua"])
    # media
    ExtractFolder(source=os.getcwd(), dest=FOLDER_PATH, name="Media", files=["warlock_kick.tga", "kick.ogg", "kick_chinese.ogg"])
    # locales
    ExtractFolder(source=os.getcwd(), dest=FOLDER_PATH, name="Locales", files=["enUS.lua", "zhCN.lua"])
    # root files
    ExtractFile(source=os.path.join(os.getcwd(), "embeds.xml"), dest=FOLDER_PATH)
    ExtractFile(source=os.path.join(os.getcwd(), "eventHandler.lua"), dest=FOLDER_PATH)
    ExtractFile(source=os.path.join(os.getcwd(), "configure.lua"), dest=FOLDER_PATH)
    ExtractFile(source=os.path.join(os.getcwd(), "utilities.lua"), dest=FOLDER_PATH)

if __name__ == "__main__":
    CreateMFI()