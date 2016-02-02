# Resumable (chunked) uploads  in Rails 4.2 using paperclip and jQuery File Upload

## Description
This is an example implementation of [jQuery File Upload](https://github.com/blueimp/jQuery-File-Upload) under Rails 4.2 using [Paperclip](https://github.com/thoughtbot/paperclip). The app uses the gem [jquery-fileupload-rails](https://github.com/tors/jquery-fileupload-rails) to integrate the relevant libraries into the Rails Asset Pipeline.

## Installation
```
bundle install
rake db:create && rake db:migrate
```

## Features
The app has one model `Item`, which `has_attached_file :upload`