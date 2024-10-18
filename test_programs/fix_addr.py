import argparse
from tempfile import mkstemp
from shutil import move, copymode
from os import fdopen, remove


def get_command_line_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-f", "--file_name", type=str, default="" 
    )

    parser.add_argument(
        "-w", "--data_width", type=int, default=1
    )

    args = parser.parse_args()

    file_name = getattr(args, "file_name")
    data_width = getattr(args, "data_width")

    return file_name, data_width

def fix_address(line, data_width):
    if line[0] == "@":
        mem_addr = int(line[1:], 16)
        mem_addr = mem_addr // 4
        line = f"@{mem_addr:0{8}X}\n"
    return line

def fix_addresses(file_name, data_width):
     #Create temp file
    fh, abs_path = mkstemp()
    with fdopen(fh,'w') as new_file:
        with open(file_name) as old_file:
            for line in old_file:
                new_file.write(fix_address(line, data_width))
    #Copy the file permissions from the old file to the new file
    copymode(file_name, abs_path)
    #Remove original file
    remove(file_name)
    #Move new file
    move(abs_path, file_name)

if __name__ == "__main__":
    file_name, data_width = get_command_line_args()
    fix_addresses(file_name, data_width)

