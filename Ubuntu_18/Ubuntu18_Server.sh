# Ubuntu x64: 18.04, 18.10 

# 1)  Create a new Droplet in Digitalocean (select ssh keys for the laptop). 
# 2) Then, inside the droplet (login as root),  create a file called "automatic" and paste the content of this FILE
# 3) Also, create a file called ".env" at the same level of "automatic"
# 4) Execute: chmod 775 automatic
# 5) Execute: ./automatic
# 6) Logout and Login with one of the users created

#####################################################################

if [ ! -f .env ]; then
    echo "File .env not found!"
    exit 0
fi

export $(cat .env | grep -v "#" | xargs)

# Update and Upgrade the System
sudo apt-get update && sudo apt-get upgrade -y &&
sudo apt autoremove -y;

# NI= Install GIT
    sudo apt-get install git -y;
	git config --global user.email $ENV_GIT_EMAIL;
	git config --global user.name $ENV_GIT_USER_NAME;
	git_version=$(git --version);
	echo -e "\e[31m$git_version\e[39m";

# NI= Install UFW (Firewall)
sudo apt-get install ufw -y;
sudo ufw status &&
sudo ufw default deny incoming &&
sudo ufw default allow outgoing &&
#sudo ufw allow 'Nginx HTTP' &&
# www required to accept domains on port 80
sudo ufw allow www &&
# 443/tcp required to accept domains on port 443
sudo ufw allow 443/tcp &&
sudo ufw allow ssh &&
sudo ufw --force enable;

# Install Midnight Commander
sudo apt-get install mc -y;

# Generate ssh-keygen
ssh-keygen -t rsa -b 4096 -C "root-public-key" -P "" -f "/root/.ssh/id_rsa" -q &&
eval $(ssh-agent -s) &&
ssh-add ~/.ssh/id_rsa &&
cat /root/.ssh/id_rsa.pub;


# Create One User called "Developer"
    new_user=developer;

    # Create new User and add it to Sudoers list
    # https://askubuntu.com/questions/420784/what-do-the-disabled-login-and-gecos-options-of-adduser-command-stand
    adduser --disabled-password --gecos "" $new_user; 

    #Add a password
    echo $new_user:$ENV_UBUNTU_PASSWORD | chpasswd;
    echo $new_user'  ALL=(ALL:ALL) ALL' >> /etc/sudoers;

    # -p = creates dirs in the path if does not exists). 
    sudo mkdir -p /home/$new_user/.ssh &&
    sudo chmod 700 /home/$new_user/.ssh;

    # Generate ssh-keygen    
    ssh-keygen -t rsa -b 4096 -C "$new_user-public-key" -P "" -f "/home/$new_user/.ssh/id_rsa" -q
    cat /home/$new_user/.ssh/id_rsa.pub

    # To Copy the ssh authorized keys from root to the user (these keys were generated by digital ocean when creating the droplet)
    sudo cp /root/.ssh/authorized_keys /home/$new_user/.ssh/authorized_keys;
    sudo chmod 644 /home/$new_user/.ssh/authorized_keys &&
    sudo chown -R $new_user:$new_user /home/$new_user/.ssh
    #  &&
    # sudo chown $new_user:$new_user /home/$new_user/.ssh/authorized_keys &&    
    # sudo chown $new_user:$new_user /home/$new_user/.ssh/id_rsa &&
    # sudo chown $new_user:$new_user /home/$new_user/.ssh/id_rsa.pub;
    

# Install Fail2ban (Avoid Brute Force attack)
sudo apt-get install fail2ban -y;


# Install Docker
# https://www.digitalocean.com/community/tutorials/como-instalar-y-usar-docker-en-ubuntu-18-04-1-es
    sudo apt install apt-transport-https ca-certificates curl software-properties-common &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" &&
    sudo apt update &&
    apt-cache policy docker-ce &&
    sudo apt install -y docker-ce &&
	sudo systemctl enable docker &&
    docker --version;

    # Config sudo docker (avoid use of sudo)
    sudo usermod -a -G docker $new_user;


# Install docker-compose
# https://www.digitalocean.com/community/tutorials/como-instalar-docker-compose-en-ubuntu-18-04-es

    # Dated Feb 09 2021: Version 1.28.2 has a bug with network_mode host
    sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose &&
    sudo chmod +x /usr/local/bin/docker-compose &&
    docker-compose --version;


# Automatic Commands to manage DOCKER
    # $new_user
        sudo mkdir /home/$new_user/Execute &&
        # This repository must be PUBLIC (to avoid the use of credentials)
        sudo git clone https://github.com/pablodonayre/Execute_Docker.git docker &&
        sudo mv docker /home/$new_user/Execute/ &&
        sudo chmod -R 755 /home/$new_user/Execute &&
        sudo chown -R $new_user:$new_user /home/$new_user/Execute &&
        echo alias dock-del-c=/home/$new_user/Execute/docker/docker-delete-containers.sh >> /home/$new_user/.bashrc &&
        echo alias dock-del-all=/home/$new_user/Execute/docker/docker-delete-all.sh >> /home/$new_user/.bashrc &&
        echo alias dock-del-img=/home/$new_user/Execute/docker/docker-delete-images.sh >> /home/$new_user/.bashrc &&
        echo alias dock-del-vol=/home/$new_user/Execute/docker/docker-delete-dangling_volumes.sh >> /home/$new_user/.bashrc;


# Install Python3
sudo apt install python3;

