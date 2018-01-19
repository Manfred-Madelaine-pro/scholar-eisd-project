local struct = {}

function struct.foo()
	name = "manfred"
	lastname = "MFD"
	birth = "1"
	death = nil
	birthplace = "mada"

	famille = "yo"
	formation = "yo"

	p = struct.Politician(name, lastname, birth, death, birthplace, famille, formation)
	struct.print_struct(p)
end


--[[
	Constructeur de la classe Politicien
]]--
function struct.Politician(name, lastname, birth, death, birthplace, famille, formation)
	p = {}
	p["personne"] = struct.Personne(name, lastname, birth, death, birthplace)

	p["famille"] = famille
	p["formation"] = formation
	--[[
	p[""] = 
	p[""] = 
	p[""] = 
	p[""] = 
	p[""] = ]]
	return p
end

function struct.Politician2(personne, birthplace, famille, formation)
	p = {}
	p["personne"] = personne

	p["famille"] = famille
	p["formation"] = formation
	--[[
	p[""] = 
	p[""] = 
	p[""] = 
	p[""] = 
	p[""] = ]]
	return p
end


function struct.Personne(name, lastname, birth, death, birthplace)
	p = {}

	p["name"] = name
	p["lastname"] = lastname

	p["birth"] = birth
	p["death"] = death
	p["birthplace"] = birthplace

	return p
end


function struct.Famille()
	--[[
		Nom : Georges Mélenchon
	Profession : receveur des Postes
	Statut : père
	Naissance :
	Décès : 
	]]
end


function struct.print_struct(my_struct)
	for index, valeur in pairs(my_struct) do
    	txt = index.." : "..valeur

    	print(txt)
    end
end


return struct