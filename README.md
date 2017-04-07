# Discourse User Feedback

## Features
* Go to /u/[username]/activity/feedback to see that user's feedbacks left by others.
* In that same page you can leave your feedback for the user.
* You can see an average rating in the user's profile as well as in the user card.

## TO-DO
* Trigger a notification when someone gives you feedback.

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
