# README

## Introduction

This Rails 4 app sets up the basic code for a skeleton app:

* There some basic models, each meant to do somethign interesting:
  * Task: It borrows code from a standard scaffold structure. It showcases a simple association - belongs_to :owner, class_name: "User"
  * Location: It showcases geocoding.
* Devise and Cancan are set up:
  * Devise uses User as the model for authentication; no other config changes are made for Devise other than those in the default gem. Devise views are installed.
  * CanCan uses a simple authentication using the Task => User association
* Views (for Task) use HAML
* Controllers use strong parameters
* The layout puts notice and alert at the top of the page, and a float:right element to accommodate the user session (logged-in/out) state.
* Layouts uses Twitter Bootstrap CSS.
* Forms use [Formtastic Bootstrap](https://github.com/mjbellantoni/formtastic-bootstrap).

## Testing

The app also has some basic tests:

* It uses RSpec - `rails g rspec:install` has already been run for you.
* It uses Capybara.
* Unit tests for users and tasks - check that users can be created, and that tasks cannot be created when a user is not logged in.
* Integration tests: None so far

## How Did The App Get Here?

If you are trying to do this from scratch, note that the following `rails` and `rake` commands are essential to getting the app to its current state, after your bundle is installed (though you also have to change the code obviously).

This list is unfortunately *not* complete - it's pretty hard to keep the list of migrations up-to-date. :(

    rails new baseline_rails_4_install
    rails generate model Task title:string owner_id:integer
    rails generate scaffold Location lat:float long:float name:string address:string	
    rails g migration AddAdminToUser admin:boolean
    rails g migration AddAgeToUser age:integer

These generate files, so you don't have to re-run them, but they are here for the sake of the record. This list too is probably incomplete:

    # Devise
    rails generate devise User
    rails generate devise:views

    # CanCan
    rails g cancan:ability

    # For rspec tests folders
    rails generate rspec:install

    # For formtastic
    rails generate formtastic:install
