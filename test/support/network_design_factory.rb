# Builds the records the request wizard creates: a company, its design
# request, the physical spaces, the logical design and its subnets.
module NetworkDesignFactory
  def create_user(email: 'designer@ldws.local', role: 'User')
    User.create!(email: email, password: 'test-password', password_confirmation: 'test-password',
                 role: role, name: 'Network Designer')
  end

  def create_design(user: create_user, rooms: [{ computers: 40 }], subnets: {}, scalability: 20,
                    ctype: 'Enterprise', redundancy: false, services: {})
    company = Company.create!(name: 'Acme S.A.S.', nit: '900123456', email: 'it@acme.test', user_id: user.id)
    request = Request.create!({ title: 'Red sede principal', company_id: company.id, ctype: ctype }.merge(services))
    building = Building.create!(name: 'Principal', distance: 0, request_id: request.id)
    rooms.each do |room|
      Physical.create!({ request_id: request.id, building_id: building.id, height: 3, width: 6, large: 8,
                         printers: 1, conference_hall: false }.merge(room))
    end
    logical = Logical.create!(request_id: request.id, host1: 192, host2: 168, host3: 10, host4: 0,
                              redundancy: redundancy, scalability: scalability, security: true)
    subnets.each do |name, computers|
      Subnet.create!(name: name, description: name, computers: computers, logical_id: logical.id)
    end

    request
  end
end
