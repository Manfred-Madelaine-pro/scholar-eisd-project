local struct = {}

function struct.foo()
	name = "Jean-Luc"
	lastname = "Mélenchon"
	birth = "19 août 1951"
	death = nil
	birthplace = "Tanger (Maroc)"

	pers = struct.Personne(name, lastname, birth, death, birthplace)


	pere = struct.Personne("Georges", "Mélenchon", nil, nil, "France")
	mere = struct.Personne("Jeanine", "Bayona", nil, nil, "France")

	famille = {struct.Famille(pere, "père"), struct.Famille(mere, "mère")}
	
	formation = nil

	parti = "La France Insoumise"

	p = struct.Politician(pers, famille, formation, parti)
	struct.print_struct(p)
end


--[[
	Constructeur de la classe Politicien
]]--
function struct.Politician(personne, famille, formation, parti)
	p = {}
	p["personne"] = personne

	p["famille"] = famille
	p["formation"] = formation

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


function struct.Famille(personne, statut)
	fam = {}

	fam["personne"] = personne
	fam["statut"] = statut

	return fam
end


function struct.print_struct(my_struct)
	for index, valeur in pairs(my_struct) do
		if type(valeur) == "table" then
			struct.print_struct(valeur)
			print("\n")
		else
	    	txt = index.." : "..valeur
    		print(txt)
		end

    end
end


return struct