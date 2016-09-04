#
# Description: Log all objects stored in the $evm.root hash.
#        Then log the attributes, associations, tags and
#        virtual_columns for each automate service model.
#

def dump_tags(object)
  return if object.tags.nil?

  $evm.log("info", "  Begin Tags [object.tags]")
  object.tags.sort.each do |tag_element|
    tag_text = tag_element.split('/')
    $evm.log("info", "    Category:<#{tag_text.first.inspect}> Tag:<#{tag_text.last.inspect}>")
  end
  $evm.log("info", "  End Tags [object.tags]")
  $evm.log("info", "")
end


def dump_attributes(object)
  $evm.log("info", "  Begin Attributes [object.attributes]")
  object.attributes.sort.each { |k, v| $evm.log("info", "    #{k} = #{v.inspect}") }
  $evm.log("info", "  End Attributes [object.attributes]")
  $evm.log("info", "")
end

user = $evm.root['user']
$evm.log("info", "=== Dumping User Attributes ===")
dump_attributes(user)
$evm.log("info", "=== Dumping User Tags ===")
dump_tags(user)

group = $evm.root['miq_group']
$evm.log("info", "=== Dumping Group Attributes ===")
dump_attributes(group)
$evm.log("info", "=== Dumping Group Tags ===")
dump_tags(group)


#Pull the user name out of the LDAP by attribute, else use the username in the CFME DB
ldap_username_attr = group.tags("ldap_username_attribute")[0]

unless ldap_username_attr.nil?
  user_name = user.get_ldap_attribute(ldap_username_attr)
  $evm.log("info","Found user_name in LDAP => #{user_name}")
else
  user_name = user.name
  $evm.log("info","Unable to get username by attribute.  Procceding with user_name as #{user_name}")
end


ldap_manager_attr = group.tags("ldap_manager_attribute")[0]
#Pull the manager name out of the LDAP by attribute
unless ldap_manager_attr.nil?
  manager_id = user.get_ldap_attribute(ldap_manager_attr)
  $evm.log("info","Found manager_name in LDAP => #{manager_id}")
  
   
  vmdb = $evm.vmdb('user').methods
  $evm.log("info","#{vmdb.inspect}")
  
  
else
  $evm.log("info","Unable to get manager_name by attribute")
end


