# Rails6 PostgreSQL Blog
 * April 2020
 * Rails 2.6.3

# _Setting up the basics_

### __Create a new Rails app__
  * `rails new rails6-pg-blog -t -d postgresql -b`
    * `-t` disallows test autogeneration.
    * `-d` requires a different database than the default MySQL (I specified postgresql).
    * `-b` disallows the automatic bundle (since I will be altering the Gemfile, I will be bundling anyway).
    * A complete list of options can be seen by using `rails new --help`.

### __Update Gemfile__
  * Paste over default Gemfile:
    ```
    source 'https://rubygems.org'
    git_source(:github) { |repo| "https://github.com/#{repo}.git" }

    ruby '2.6.3'

    gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
    gem 'puma', '~> 4.1'
    gem 'sass-rails', '>= 6'
    gem 'webpacker', '~> 4.0'
    gem 'turbolinks', '~> 5'
    gem 'jbuilder', '~> 2.7'
    gem 'dotenv-rails'
    gem 'bootsnap', '>= 1.4.2', require: false

    group :development, :test do
      gem 'sqlite3', '~> 1.3', '>= 1.3.11'
      gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
    end

    group :development do
      gem 'web-console', '>= 3.3.0'
      gem 'listen', '>= 3.0.5', '< 3.2'
      gem 'spring'
      gem 'spring-watcher-listen', '~> 2.0.0'
    end

    group :production do
      gem 'pg', '>= 0.18', '< 2.0'
    end

    group :test do
      gem 'capybara', '>= 2.15'
      gem 'selenium-webdriver'
      gem 'webdrivers'
    end

    gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
    ```

### __Update Database.yml__
  * This App uses SQLite3 for development & test, and PostgeSQL for production.
  * This App also uses DotEnv for secret variables. This is covered in the next section.
    ```
    development:
      adapter: sqlite3
      database: db/rails6_pg_blog_development.sqlite3
      pool: 5
      timeout: 5000

    test:
      adapter: sqlite3
      database: db/rails6_pg_blog_test.sqlite3
      pool: 5
      timeout: 5000

    production:
      adapter: postgresql
      encoding: unicode
      pool: 5
      database: rails6_pg_blog_production
      username: <%= ENV['RAILS6_PG_BLOG_DATABASE_USERNAME'] %>
      password: <%= ENV['RAILS6_PG_BLOG_DATABASE_PASSWORD'] %>
      # url: <%= ENV['DATABASE_URL'] %>
    ```
  * For other Database options use this [reference](https://gist.github.com/jwo/4512764) to suit your needs.

### __Setup Envionmental Variables ([DotEnv](https://github.com/mikamai/dotenv))__
  * Create an Envionment Varaible file in the root of your project:
    * `touch .env`
  * Paste into the blank .env file:
    ```
    RAILS6_PG_BLOG_DATABASE_USERNAME=rails6_pg_blog_admin
    RAILS6_PG_BLOG_DATABASE_PASSWORD=<Omitted>
    ```
  * _Note that I have omitted the password as this is a live app. I suggest generating a random password (I use [LastPass](https://www.lastpass.com/))._

### __Update .gitignore__
  * Now that we have Envionmental Variables (Secrets), we don't want them to end up on Github or anywhere else that isnt secure.
  * Paste this over the default code in .gitignore:
    ```
    # Ignore bundler config.
    /.bundle

    # Ignore all logfiles and tempfiles.
    /log/*
    /tmp/*
    !/log/.keep
    !/tmp/.keep

    # Ignore uploaded files in development.
    /storage/*
    !/storage/.keep

    /public/assets
    .byebug_history

    # Ignore master key for decrypting credentials and more.
    /config/master.key

    /public/packs
    /public/packs-test
    /node_modules
    /yarn-error.log
    yarn-debug.log*
    .yarn-integrity

    # Ignore Envionmental Variables.
    .env
    /db/rails6_pg_blog_development.sqlite3
    /db/rails6_pg_blog_test.sqlite3
    ```

### __Setup Github & Git Commit__
  * Let's save our work, now that all the basics are setup properly.
  * Create a Github Repository & copy the provided HTTP link.
  * In the root directory, paste in the following commands (using your Githubs HTTP link):
  * `git remote add origin [GITHUB_URL]`
  * Push up to Github:
  * `git add .`
  * `git commit -m "Basics implemented for Gemfile, .env, .gitignore, Database.yml, Readme.md"`
  * `git push origin master`

# _Building the Blog_

### __Schema Critical Thinking__
  * Before we can generate models, we have to know what those models need.
  * First I need to make out a basic wireframe so I can visualize the App and discern what I need. I use whiteboards, but you can also use something like [Paint](https://jspaint.app/).
  * I have made one using both options for example:
  * ![Paint Wireframe Example](/app/assets/images/readme/paint_example.png?raw=true "Paint Wireframe Example")
  * ![Whiteboard Wireframe Example](/app/assets/images/readme/whiteboard_example.png?raw=true "Whiteboard Wireframe Example")
  * Using this example, I know that for the MVP (Minimum Viable Product) I will need:
    * A User Model with the fields:
      * id (Automatically Generated)
      * name
      * avatar
      * created_at (Automatically Generated)
      * updated_at (Automatically Generated)
    * An Article Model with the fields:
      * id (Automatically Generated)
      * user_id foreign key
      * title
      * text
      * image
      * post_date
      * created_at (Automatically Generated)
      * updated_at (Automatically Generated)
  * If you wanted to see this laid out in a more proper schema setting (usually for more complex schemas) you can use [dbdiagram](https://dbdiagram.io/d).
    * I created an [example schema]() for this project using dbdiagram.
    * ![Whiteboard Wireframe Example](/app/assets/images/readme/dbdiagram_example.png?raw=true "Whiteboard Wireframe Example")
  * If you don't know what those things are, don't worry, we'll cover it all soon.
  * Now that we know the basics we'll need for the MVP, we can generate some models.

### __Generating the Model(s)__
  * Lets generate the model using the rails generator:
    * `rails g model users name:string avatar:string`
      * _Note that the avatar is a string. This is because we will be storing the file itself locally and will only need a relative path._
  * Now we will repeat the process for our Articles model:
    * `rails g model articles user_id:references title:string text:string image:string post_date:datetime`
      * *Note that the user_id is a reference, this will setup Article to have `user_id:integer` & automatically make it `belongs_to` a user_id. However, we will still have to update user.rb with `has_many`.*
      * *Note that the image is a string just like the users avatar.*
  * This will generate multiple files for each model, though we only need two for each:
    * The Migrations at /db/migrate/. They should look similar to this with different numbers:
      * `20200417215133_create_users.rb`
      * `20200417220134_create_articles.rb`
    * The Models at /app/models
      * `user.rb`
      * `article.rb`
    * _Note that the migrations are plurel and the Models are singular. Thats normal naming convention for this_
  * Open /app/models/user.rb and overwrite the file:
    ```
    class User < ApplicationRecord
      has_many :articles
    end
    ```
  * Now that our Models are in place, we can migrate our database:
    * `rake db:migrate`
  * 

### __________________
  * 
  * 
  * 
  * 
  * 
  * 

### __________________
  * 
  * 
  * 
  * 
  * 
  * 

### __________________
  * 
  * 
  * 
  * 
  * 
  * 