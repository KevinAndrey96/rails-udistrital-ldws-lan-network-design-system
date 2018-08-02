# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(email: 'kaherreras@unal.edu.co', role: 'Admin', name: 'Kevin Andrey Herrera Silva', password: 'REDACTED', password_confirmation: 'REDACTED')
User.create(email: 'collaborator@ldws.local', role: 'Admin', name: 'LDWS Collaborator', password: 'REDACTED', password_confirmation: 'REDACTED')
User.create(email: 'admin@ldws.com', role: 'Admin', name: 'Administrador LDWS', password: 'REDACTED', password_confirmation: 'REDACTED')
puts "DefectoOk"