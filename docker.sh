sudo apt-get update

# Install Docker dependencies
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
# Download and save Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update & install
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Create docker group if not already present
sudo groupadd docker

# Add your user to it
sudo usermod -aG docker $USER

# Apply changes (log out & back in, or run)
newgrp docker

# Test
docker run hello-world
