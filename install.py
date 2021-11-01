import os

# have file called depend.txt
# contains all the dependencies needed to install
# go through each dependency and pip install each one using os.system()


def install():
    print("Installing dependencies...")
    filename = "depend.txt"
    num_d = 0

    with open(filename, "r") as f:
        dependencies = f.read().splitlines()
        num_d = len(dependencies)
        for d in dependencies:
            command = "pip install --user " + str(d)
            # print(command)
            os.system(command)

    f.close()
    print(str(num_d) + " dependencies installed")
