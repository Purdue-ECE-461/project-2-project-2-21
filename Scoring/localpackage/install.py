"""Installs the dependencies of the project."""

import os

# have file called depend.txt
# contains all the dependencies needed to install
# go through each dependency and pip install each one using os.system()


def install():
    """
    Installs all dependencies listed in depend.txt file
    """
    print("Installing dependencies...")
    filename = "depend.txt"
    num_d = 0

    with open(filename, "r", encoding="UTF-8") as file:
        dependencies = file.read().splitlines()
        num_d = len(dependencies)
        for dep in dependencies:
            command = "pip3 install --user " + str(dep)
            # print(command)
            os.system(command)

    file.close()
    print(str(num_d) + " dependencies installed")
