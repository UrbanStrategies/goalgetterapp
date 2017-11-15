# Alameda County Office of Education

Goal Getter App

# Setting up the app

Note: requires Ruby knowledge, Heroku experience

* Create a Heroku app, with a Postgres database. Set the following environment variables:
  * `ADMIN_PASSWORD`
* After installing to Heroku, and running `rake db:migrate`, initialize with:
  ```

    heroku run rake db:seed:make_admin -a appname
    heroku run rake db:seed:make_portfolio_categories  -a appname
    heroku run rake db:seed:make_taxonomy_nodes  -a appname
    heroku run rake db:seed:make_programs_and_organizations  -a appname # This currently loads Alameda County (CA) data
    heroku run rake db:seed:make_categorizations  -a appname # This currently loads Alameda County (CA) data
    
  ```

* To use the email-to-app feature, you need to do the following:
  * set up a Sendgrid account for transactional email.
  * The environment variables SENDGRID_USERNAME` and `SENDGRID_PASSWORD` need to be set - the latter is a Sendgrid API key. The app sends emails from the domain set in the variable `MAILER_HOST`.
  * Responses to the above host need to be set up to trigger a webhook, which points to the path `/chat_records?api_key=1` on the app's domain. This parses the email and the `To:` header to figure out how to store the email in the database.
* Admin accounts can use a [special interface](https://www.goalgetterapp.org/admin/assignment?type=student-to-school) to upload data - the upload file should be in [this format](https://docs.google.com/spreadsheets/d/16KGSdv0TC0qGP9ZC5r356ivdqCWrpXcCwBvobOMEmsc/edit#gid=0)
* Profile Images are stored in S3 - via Paperclip. The following environment variables have to be set:
  * AWS_AKI: access key id (IAM)
  * AWS_SAK: secret access key (IAM)
  * S3_REGION
  * S3_BUCKET
  
  Make sure you turn on bucket hosting on the bucket for Paperclip to work.

* To automatically filter services down to the ones relevant to the network, add an environment variable called `NETWORK_NAME`. Create a `TaxonomyNode` whose `node_name` value is the same as this variable.

# Friends

For demo purposes, you can run `rake db:seed:make_students` to create some students. There should already be a school in the database for this to work.

# Reports

Reports are sent to the email specified in the environment variable `ADMIN_EMAIL_RECIPIENT`. The following reports are available:

* Get the latest login time for all students: `rake users:report_logins`

# General App Usage Manual

* Bookmark a specific screen by adding `screen=<screen_name>` to the URL as a query parameters, for example, `https://www.goalgetterapp.org/?screen=add-service` The list of screen names will be provided at a later date.

# Using as a Counselor

If you want to view the app as an counselor, then go to `https://www.goalgetterapp.org/?role=admin`.

# Admin Interfaces

## Create a new user

* Start at /admin_interface
* Create a new user, setting just the email and password
* Go to the Profiles tab
* Note that there's a new profile now - edit to set name, type ('counselor' or 'student') and picture.

## Upload Multiple Users

Start at `https://www.goalgetterapp.org/admin/assignment` - the screen has an upload file button where you can upload a
tab-separated values file, with one user in each row. The column ordering is explained on the page above.

## Assign a student/counselor to a school

* Start at /admin/assignment?type=counselor-to-school or admin/assignment?type=student-to-school

# Contributing

These are notes to help folks contribute to this code base.

# Data Model

* The list of achievements is stored as `profile_entries` records in the DB. Each record has an `entry_key` column which is set to either 'work' or 'achievement'.

# SPA (views/front end code) Basics

* Written using Backbone JS
* In `models/app_body_model`, a variety of properties are initialized that essentially manage the SPA. This is delegated off to a Helper class in `goal_getter/helpers/model_initializer.js`, and contains among other things:
  * a navigation structure, that models a tree navigation format, via a `levels` hash and an `up_level` "pointer" hash,
  * a `texts` hash that shows each level's "title"
  * a `header_config` hash that configures many things:
    * Which icons show in the header via the following keys:
        * `done_refreshes`: if the Done action on a form screen would cause the parent screen to refresh 
  * `requires_login`: hash that controls whether the screen requires login
  * Hashes that remember state, like if a screen's data has been obtained,
  * `overlay_texts`: controls what is shown in a popup that the screen may have.
  * and so on.
* A main `control_view` creates a header and a footer view. The header view delegates screen creation to `app_body_view`
  * `app_body_view` creates the individual body screens on demand, and dynamically finds the corresponding view class for each body screen using a name resolution helper method. See more in the *Under The Hood* section. 
  * This dynamic creation also runs a data fetch prior to view rendering. The URL for the data fetch is determined in `models/app_body_model.js` in the method `make_url`. Following the code from there will help determine the internal business logic for how data is laid out.

# Checking Login

The basic page data is stored in the div `page_data`. When the model initializes, it checks this div for various pieces
of config data, as it were. If the backend confirmed login, then `data-login-token` is set to `user', `admin` or `none`. If set to _none_ views requiring logins are not rendered. 

# Fetching data

Data is fetched in `models/app_body_model.js`, in the method `fetch_screen`.

The rendering of fetched data is defined in a base class that all views inherit from, in
`views/base/screen_base.js`. When it knows it has data, it triggers `body:render` which is heard by `AppBodyView`, which
passes this knowledge to `HeaderView`. This view then triggers its `render` method, which causes the body view to
actually be rendered.

`HeaderView` also decides what to do when the user is not logged in - instead of rendering the actual view, it pretends
that it needs to render the `logged-out` screen.

# Navigation

* Navigation happens via an event called `navigation:change` that is listened to by `HeaderView`, which calls
  `change_screens`. The view uses `AppBodyModel` to handle data about overall navigation. In some places, the app also
  calls `change_screens` directly - the main reason is to supply special parameters, like `from` and `to` that help
  manage the custom history within the SPA.

The following methods navigate to a new screen:

1. Get the `HeaderView` to call `change_screens` with an object as the first argument, whose `to` property is set to the name of the destination screen.
1. Call `pass_navigation()` on an `AppBodyView` instance, with an "options" object (description TBD - it takes the following keys among other details: `to`: the key of the screen to switch to)

# Data Retrieval

## The Portfolio View

This view is a bit complicated because it has its own sub-tab structure, whose logic is somewhat duplicated relative to
how screens are managed for the bottom-menu navigation.

If the view is for a shared, public, link, which is triggered by the query parameters `screen_name=public-portfolio`, then ---

Each tab is ultimately fetched via the same path, that is, first to `profiles_controller#show` which passes it on to `services/data_fetchers#portfolio_data`

# Styling

The styles are largely dependent on the [Materialize framework](http://materializecss.com/). Make sure to read through `variables.scss` and `mixins.scss` to get a sense of the conventions used specific to the app.

# Creating entry forms

The *Add Service* and *Add Milestone* templates are good examples for the logic behind the structure of an input form. The action happens in `render_and_close()` in `AppBodyView`.

Essentially, if there is a unique element with the class `.input-form`, then a server code is extracted from this element from its `data-server-code` attributes, all of its `input` tag elements are collected as an array, and these two are passed to `AppBodyModel.process_form_data()`.

This runs an async process via `Helpers::FormProcessor.run()`, which returns a Promise. The above `run()` method uses
the `name` attribute and `val()` value of each `input` node. The `val()` value is overridden by a `data-val` attribute
if it exists - this allows the value that's shown to the user to be different than the one sent to the server. The
method then sends a JSON payload which contains the server code and the array of inputs to the end point,
`/ajax_requests`.

**Currently, the form processor above enforces that all fields are always required.**

*Rendering Screen After Update*: After the form successfully submits, `AppBodyView::render_and_close()` is called. It determines if the parent screen needs to be refreshed and if so, calls `render()` on it. 

# Backend

* Attemps to be XHR only, though it doesn't use Rails 5 API which it probably should but development started before Rails 5 was past RC.
* AJAX: look at how AJAX requests controller works - there are some "codes" that can be sent via XMLHTTP requests that are multiplexed in this controller. For updating data, the code `data-change` then further multiplexes the update into various models.

## Schema

* User accounts have Profiles, which store all the relevant information about a user. E.g., the `profile_type` column in `profiles` decides if the user is a student or counselor.

## Database

* You can seed the database with some dummy values after migration:
  * `rake db:seed`
  * `rake db:seed:make_portfolio_categories`
  * `rake db:seed:make_taxonomy_nodes` (This is keyed in to the names in the Programs and Organizations data for Alameda County.)
* Alameda County seed data has been produced in Ruby/ActiveRecord format in `db/seeds/make_programs.rb`. Load it with `rake db:seed:make_programs_and_organizations` and `rake db:seed:make_categorizations`
* If Programs haven't already been geo-coded, you can use `db/seeds/initialize_lat_lon.rb` to do so. It will set lat/lon values to -1 if the geocode fails. It rate-limits itself to 3 requests per second, so expect it'll take a while if you have a lot of entries.

# External Dependencies

## JS based libraries

* Materialize: managed via gems
* Leaflet: in `vendor/assets/`
* Dropzone: in `vendor/assets/`

To update, run a package manager to install/upgrade globally (say, [YarnJS](https://yarnpkg.com/)), and copy the updated files, if any, to the vendor folder. For example, if you use `[YarnJS](https://yarnpkg.com/)`,

    yarn global add leaflet # or yarn upgrade leaflet
    yarn global add dropzone # or yarn upgrade dropzone
    cp ~/.yarn-config/global/node_modules/leaflet/dist/leaflet.css vendor/assets/stylesheets
    cp ~/.yarn-config/global/node_modules/leaflet/dist/leaflet.js vendor/assets/javascripts
    cp ~/.yarn-config/global/node_modules/dropzone/dist/leaflet.css vendor/assets/stylesheets
    cp ~/.yarn-config/global/node_modules/dropzone/dist/leaflet.js vendor/assets/javascripts

# Deploying to a bare Ubuntu (Linux) box

* Set up Postgres and Passenger as per usual. Make sure to grant both database, schema and sequence access to the Postgres user configured for db access in `config/database.yml`
* Use the `.env` file which is read by the gem [`Dotenv`](https://github.com/bkeepers/dotenv) to set the environment.
* PG backups have been configured using [PG Barman](http://docs.pgbarman.org/)
* Create an SSL certificate for the app - the production environment defaults to SSL.
* The repository contains Systemd service files for starting Sidekiq and Redis. Use `apt-get` to install Redis. Sidekiq will work because it's already in the app's bundle.
* Set up RVM and add the mail receiver user and the app server user as members of the `rvm` group.
* Emails are sent via localhost - configure Sendmail to act as an MTA with localhost access. The sender domain must be set in the app's environment via the `.env` file.
* Emails are received by the user `goalg` and processed via `procmail`. The `procmail` recipe calls the custom task `make_log` which is in `db/seeds/make_log.rb`
* Point an MX record for the domain to the app server.

## Dependencies

* `apt-get install libpq-dev`
* For Capybara-Webkit, if you are doing testing/development as well: `apt-get install qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x`