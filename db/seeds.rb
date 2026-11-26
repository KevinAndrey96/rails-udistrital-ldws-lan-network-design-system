# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'securerandom'

admin_email = ENV.fetch('LDWS_ADMIN_EMAIL', 'admin@ldws.local')
unless User.exists?(email: admin_email)
  admin_password = ENV['LDWS_ADMIN_PASSWORD'].presence || SecureRandom.urlsafe_base64(12)
  User.create!(email: admin_email, role: 'Admin', name: 'Administrador LDWS',
               password: admin_password, password_confirmation: admin_password)
  puts "Admin: #{admin_email} / #{admin_password}" if ENV['LDWS_ADMIN_PASSWORD'].blank?
end

Port.create(name: "RJ45-1", speed: "1")
Port.create(name: "SFP", speed: "1")
Port.create(name: "SFP+", speed: "10")
Port.create(name: "QSFP", speed: "10")
Port.create(name: "QSFP+", speed: "40")
Port.create(name: "RJ45-10", speed: "10")

Ethernet.create(name: "10GBASE-SR", speed: "10", distance: "33")
Ethernet.create(name: "10GBASE-LX4", speed: "10", distance: "300")
Ethernet.create(name: "10GBASE-SR", speed: "10", distance: "82")
Ethernet.create(name: "10GBASE-LX4", speed: "10", distance: "300")
Ethernet.create(name: "100GBASE-SR10", speed: "100", distance: "100")
Ethernet.create(name: "40GBASE-SR4", speed: "40", distance: "100")
Ethernet.create(name: "10GBASE-SR", speed: "10", distance: "300")
Ethernet.create(name: "10GBASE-LX4", speed: "10", distance: "300")
Ethernet.create(name: "100GBASE-SR10", speed: "100", distance: "150")
Ethernet.create(name: "40GBASE-SR4", speed: "40", distance: "150")
Ethernet.create(name: "10GBASE-SR", speed: "10", distance: "490")
Ethernet.create(name: "10GBASE-LX4", speed: "10", distance: "300")
Ethernet.create(name: "1000BASE-T", speed: "1", distance: "100")
Ethernet.create(name: "10GBASE-T", speed: "10", distance: "50")

Connector.create(name: "SC", price: "2")
Connector.create(name: "LC", price: "2")
Connector.create(name: "RJ45", price: "1")
Connector.create(name: "Transceiver SFP", price: "3")
Connector.create(name: "Transceiver SFP+", price: "3")
Connector.create(name: "Transceiver QSFP", price: "4")
Connector.create(name: "Transceiver QSFP+", price: "4")

Category.create(name: "OM1", price: "5")
Category.create(name: "OM2", price: "10")
Category.create(name: "OM3", price: "15")
Category.create(name: "OM4", price: "20")
Category.create(name: "CAT6", price: "2")
Category.create(name: "CAT6A", price: "3")

Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "1", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "2", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "3", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "4", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "5", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "6", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "7", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "8", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "9", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "10", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "11", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "1", ethernet_id: "12", category_id: "4")

Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "1", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "2", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "3", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "4", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "5", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "6", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "7", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "8", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "9", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "10", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "11", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "2", ethernet_id: "12", category_id: "4")

Cable.create(name: "Par Trenzado", ctype: "UTP", structure: "UTP", connector_id: "3", ethernet_id: "13", category_id: "5")
Cable.create(name: "Par Trenzado", ctype: "UTP", structure: "UTP", connector_id: "3", ethernet_id: "14", category_id: "6")
Cable.create(name: "Par Trenzado", ctype: "UTP", structure: "FTP", connector_id: "3", ethernet_id: "13", category_id: "5")
Cable.create(name: "Par Trenzado", ctype: "UTP", structure: "FTP", connector_id: "3", ethernet_id: "14", category_id: "6")
Cable.create(name: "Par Trenzado", ctype: "UTP", structure: "STP", connector_id: "3", ethernet_id: "13", category_id: "5")
Cable.create(name: "Par Trenzado", ctype: "UTP", structure: "STP", connector_id: "3", ethernet_id: "14", category_id: "6")

Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "1", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "2", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "3", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "4", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "5", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "6", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "7", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "8", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "9", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "10", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "11", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "4", ethernet_id: "12", category_id: "4")

Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "1", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "2", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "3", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "4", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "5", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "6", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "7", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "8", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "9", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "10", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "11", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "5", ethernet_id: "12", category_id: "4")

Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "1", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "2", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "3", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "4", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "5", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "6", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "7", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "8", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "9", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "10", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "11", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "6", ethernet_id: "12", category_id: "4")

Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "1", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "2", category_id: "1")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "3", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "4", category_id: "2")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "5", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "6", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "7", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "8", category_id: "3")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "9", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "10", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "11", category_id: "4")
Cable.create(name: "Fibra Optica", ctype: "Multimodo", structure: "Tight-Buffer", connector_id: "7", ethernet_id: "12", category_id: "4")

Switch.create(name: "Cisco", reference: "2407", price: "100")
Switch.create(name: "Huawei", reference: "4771", price: "500")

# Equipment catalog for the quotation engine. power is the quality tier
# (1 economic, 2 standard, 3 optimal), slots the rack units used (or offered,
# for racks), price in USD per unit or per metre for cable and raceway.
[
  %w(Switch TP-Link TL-SG1024D 1 180 24 1),
  %w(Switch HPE\ Aruba 2530-24G 2 950 24 1),
  %w(Switch Cisco Catalyst\ 2960X-24TS 3 2400 24 1),
  %w(Router MikroTik RB4011iGS+ 1 220 10 1),
  %w(Router Ubiquiti EdgeRouter\ 12 2 480 12 1),
  %w(Router Cisco ISR\ 4331 3 3200 3 1),
  %w(Rack Genérico Gabinete\ 12U 1 250 0 12),
  %w(Rack Genérico Gabinete\ 42U 1 690 0 42),
  %w(Rack Panduit NetRunner\ 24U 2 1100 0 24),
  %w(Rack Panduit NetRunner\ 42U 2 1600 0 42),
  %w(Rack APC NetShelter\ SX\ 24U 3 1900 0 24),
  %w(Rack APC NetShelter\ SX\ 42U 3 2600 0 42),
  %w(Cable Nexxt UTP\ Cat\ 5e 1 1 0 0),
  %w(Cable Belden UTP\ Cat\ 6 2 2 0 0),
  %w(Cable Panduit UTP\ Cat\ 6A 3 3 0 0),
  %w(Canaleta Dexson DXN10\ 20x12 1 2 0 0),
  %w(Canaleta Legrand DLP\ 32x16 2 4 0 0),
  %w(Canaleta Panduit LD5\ 50x25 3 7 0 0),
  %w(Toma Nexxt Jack\ Cat\ 5e 1 3 0 0),
  %w(Toma Leviton Jack\ Cat\ 6 2 6 0 0),
  %w(Toma Panduit Mini-Com\ Cat\ 6A 3 11 0 0),
  %w(Conector Nexxt RJ45\ Cat\ 5e 1 1 0 0),
  %w(Conector AMP RJ45\ Cat\ 6 2 1 0 0),
  %w(Conector Panduit RJ45\ Cat\ 6A 3 2 0 0),
  %w(AP TP-Link EAP225 1 90 1 0),
  %w(AP Ubiquiti UniFi\ U6\ Lite 2 130 1 0),
  %w(AP Cisco Catalyst\ 9115AX 3 750 1 0)
].each do |etype, brand, reference, power, price, ports, slots|
  Equipment.find_or_create_by!(etype: etype, reference: reference) do |equipment|
    equipment.brand = brand
    equipment.power = power.to_i
    equipment.price = price.to_i
    equipment.ports = ports.to_i
    equipment.slots = slots.to_i
  end
end

Switch.create(name: "Arista", reference: "7050QX-32S", price: "9500")

# Port layout per switch model. The reports pick access switches by their
# RJ45-1 count (18, 24 or 48) and SFP uplinks (<= 4), and core/distribution
# switches by their QSFP+ ports.
rj45 = Port.find_by!(name: 'RJ45-1')
sfp = Port.find_by!(name: 'SFP')
sfp_plus = Port.find_by!(name: 'SFP+')
qsfp_plus = Port.find_by!(name: 'QSFP+')
{
  'Cisco' => [[rj45, 24], [sfp, 4]],
  'Huawei' => [[rj45, 48], [sfp, 4]],
  'Arista' => [[qsfp_plus, 32], [sfp_plus, 4]]
}.each do |name, layout|
  switch = Switch.find_by!(name: name)
  layout.each do |port, count|
    TheSwitch.find_or_create_by!(switches_id: switch.id, ports_id: port.id) { |row| row.numberports = count }
  end
end
puts "Defecto Ok"