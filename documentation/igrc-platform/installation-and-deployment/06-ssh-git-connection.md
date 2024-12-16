---
title: "Git repository connection using SSH"
description: "Configure the Git repository to use SSH"
---

# Git repository connection using SSH

Usually, we connect to a repository from Git using HTTP (something like below).

![Git repository connection using HTTPS](./images/git_ssh_connection_example_clone_git_using_https.png)

But, did you know that is also possible to connect using SSH ?

![Git repository connection using SSH](./images/git_ssh_connection_example_clone_git_using_ssh.png)

If not, here is the procedure to follow to plug your iGRC project to Git using SSH:

## SSH configuration on Studio

First, you have to configure the SSH settings of your Studio:

- Go to the `Preferences` menu
- In it, go to `SSH2` section  
- On `General` tab, configure the home folder for SSH

> The folder should be named **.ssh** and located under your home directory (see below example). If not created yet, please do so.

![SSH home folder creation](./images/git_ssh_connection_home_folder_creation.png)

![SSH home configuration under Studio](./images/git_ssh_connection_ssh_home.png)

## Create a couple private/public keys

Then, you need to generate a couple of private/public keys. Both methods are available:

- Using the Studio  
  - Go to the `Preferences` menu
  - In it, go to `SSH2` section and go to `Key Management` tab  
  - Then, click on `Generate RSA key...` (it works the same for `Generate DSA key...`)
  - Save both private/public keys clicking on `Save Private Key...` (you can add a passphrase if you want)

![Public key generation on BitBucket](./images/git_ssh_connection_keys_generation_via_studio.png)

- Using a command line (you need the **ssh-keygen** utility available)  
  - Open your terminal
  - Using ssh-keygen command, you can generate your couple of keys (see an example of line and the result below)

![Public key generation with CMD](./images/git_ssh_connection_keys_generation_via_cmd.png)

**Note:**

> Take care about the -C option to set your exact Git account login.

- Your private and public keys should be now available (a file without extension for the private key and a **.pub** file for the public key)!

![Private/Public keys](./images/git_ssh_connection_keys_files.png)

Once your keys are created, you should now declare the public key in your Git account profile. Depending of the Git used, the principle is to copy/paste the public key. See below example with BitBucket :

![Git server account profile](./images/git_ssh_connection_public_key_declaration_to_git_profile.png)

![Git server public key declaration adding](./images/git_ssh_connection_public_key_declaration_to_git_profile_add.png)

![Git server public key declaration added](./images/git_ssh_connection_public_key_declaration_to_git_profile_added.png)

## Create and configure a SSH configuration file

The next step is to create a SSH configuration file:

- In the SSH home folder containing your keys, create a **config** file
- Put and adapt the below content with your contextual information

```properties
Host <FQDN_OF_GIT_SERVER>  
HostName <FQDN_OF_GIT_SERVER>  
IdentityFile ~/.ssh/id_rsa  
User <GIT_ACCOUNT_LOGIN> 
```

Here is an example for Identity Analytics Bitbucket:

![config file example](./images/git_ssh_connection_config_file.png)

## Plug to the Git repository

You have now all that you need to connect to the Git repository from your Studio. Copy/paste the URI from the remote Git server of the repository you want to clone.  

Let all values by default, it should work as is.

![Clone repository](./images/git_ssh_connection_repository_clone.png)

- Click on `Next`
- For the first time, you should be asked for
  - Host declaration in the SSH known hosts list
  -**known_hosts** file creation to put the host to reach

![Host connection confirmation](./images/git_ssh_connection_rsa_authentication_confirmation.png)

![known_host file creation](./images/git_ssh_connection_known_host_file_creation.png)

- You should now be asked for the selection of branches in the repository

![Repository branches selection](./images/git_ssh_connection_branch_selection.png)

From this step, you should be able to see the project in your Studio and work on it!
