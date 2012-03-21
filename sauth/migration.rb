$: << File.dirname(__FILE__)
require 'database'

ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate "db/migrate"


