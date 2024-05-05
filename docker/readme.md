This container hosts the source code for Flexwin. Flexwin relies on libraries from the SAC software package which can only be distributed by IRIS and so cannot be included in the geodynamics/flexwin docker image. Because the SAC libraries cannot be included in the docker image, it is up to the user to obtain a copy of SAC and compile flexwin within the container.

docker run -it --rm -v $HOME/flexwin:/home/flexwin_user/work geodynamics/flexwin

This command will start the flexwin docker image and give you terminal access. Any changes made in the /home/flexwin/work directory will be reflected on the host machine at home/flexwin.

In order to compile flexwin, make sure that a copy of the SAC library exists in the /home/flexwin/work directory. The easiest way to do this is:

    contact IRIS in order to download a copy of SAC for linux using this form: ds.iris.edu/ds/nodes/dmc/forms/sac/
    place your (unzipped) copy of SAC into /home/flexwin on the host machine

Flexwin relies on the environment variable SACHOME in order to find the SAC library during compilation. By default, this container sets SACHOME to /home/flexwin_user/work/sac, which is equivalent to home/flexwin on the host machine. If you want to place your copy of SAC into a directory in the container other than /home/flexwin_user/work/sac, you will need to make sure that the SACHOME variable points to your chosen location within the container.

Once SAC is available within the container, you should be able to follow the instructions in the README located in the root directory in order to compile Flexwin.
