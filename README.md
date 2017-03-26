# Discourse User Feedback

## Features
* Go to /users/[username]/activity/feedback to see that user's feedbacks left by others.
* Right there you can leave your feedback too!

## TO-DO
* Trigger a notification when someone gives you feedback.
* Show feedback stats at the top of the feedback page.

## Installation

Add this repository's `git clone` url to your container's `app.yml` file, at the bottom of the `cmd` section:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://github.com/JafethDC/discourse-user-feedback.git
          
```

Rebuild your container:

```
cd /var/discourse
git pull
./launcher rebuild app
```
