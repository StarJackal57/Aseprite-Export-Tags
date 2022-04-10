local s = app.activeSprite

if not s then app.alert("No Sprite") return end

--Tag Check
if #s.tags == 0 then app.alert("No Tags to Export") return end
	
local tag_options = {"All Tags"};

for i, tag in ipairs(s.tags) do tag_options[i+1] = tag.name; end
	
--
local dlg = Dialog("Export Tags")
local file_type_list = { "ase", "aseprite", "bmp", "gif", "jpeg", "jpg", "png",  };
local export_options = { "Strips", "Animation"}
local strip_options = {"Horizontal", "Vertical"}

local Warning = {false, false}
local Note = {false}


--"Stand" Vars
local s_close = true
local s_save = true

local s_export_tag = tag_options[1]
local s_export_type = export_options[1]
local s_export_strip_type = strip_options[1]

--Methods
local function AddLayer(_sprite, _tag, _dest, _source)

	if _source.isImage then
	
		local new_Layer = _sprite:newLayer()
						
		new_Layer.parent		= _dest
		new_Layer.name 			= _source.name
		new_Layer.opacity 		= _source.opacity
		new_Layer.blendMode 	= _source.blendMode
		new_Layer.isVisible 	= _source.isVisible
		new_Layer.isEditable 	= _source.isEditable
		
		local m
		for m = 1, _tag.frames do

			local frame = s.frames[_tag.fromFrame.frameNumber + (m-1) ]
			local new_frame = _sprite.frames[m]
			new_frame.duration = frame.duration
			local Cel = _source:cel(frame.frameNumber)
			
			if Cel ~= nil then 
				local new_Cel = new_Layer.sprite:newCel(new_Layer, new_frame, Cel.image, Cel.position)
				new_Cel.color = Cel.color
				new_Cel.opacity = Cel.opacity
				new_Cel.data = Cel.data
			
			end
			
		end
	
	else
	
		local new_Group = _sprite:newGroup()
		
		new_Group.parent		= _dest
		new_Group.name 			= _source.name
		new_Group.opacity 		= _source.opacity
		new_Group.blendMode 	= _source.blendMode
		new_Group.isVisible 	= _source.isVisible
		new_Group.isEditable 	= _source.isEditable
		
		
		for l, cur_Layer in ipairs(_source.layers) do AddLayer(_sprite, _tag, new_Group, cur_Layer) end
	
	end

end

local function UpdateDialog()

	local path, file, extension = string.match(dlg.data.dir, "(.-)([^\\]-([^\\%.]+))$")
	
	--Update Vars
	s_close = dlg.data.d_close
	s_save 	= dlg.data.d_save

	s_export_tag 		= dlg.data.d_export_tag 		
	s_export_type 		= dlg.data.d_export_type 		
	s_export_strip_type = dlg.data.d_export_strip_type 
	
	--
	gif_export = (extension == "gif" )
	can_anim_export = ( (extension == "ase" ) or (extension == "aseprite" ) or (extension == "gif" ) )
	
	--Update Stuff
	dlg	
		:modify{ id="d_export_strip_type", visible=(s_export_type == "Strips"), enabled=true}
		
		--:modify{ id="d_close", visible=true, enabled=(s_export_type == "Animation")}
		--:modify{ id="d_save", visible=true, enabled=(s_export_type == "Animation")}
	
	--Warning
	local _warning_active = false
	Warning[1] = (gif_export and (s_export_type ~= "Animation") )
	Warning[2] = ( (not can_anim_export) and (s_export_type == "Animation") )
	
	for i = 1, #Warning do
		dlg:modify{ id=("Warning_" .. tostring(i)), visible=Warning[i]}
		if Warning[i] then _warning_active = true end
		end
		
	--Notes
	Note[1] = s_export_type == "Animation"
	
	for i = 1, #Note do 
		dlg:modify{ id=("Note_" .. tostring(i)), visible=Note[i]}
		end
	
	dlg:modify{ id="ok", enabled= (not _warning_active) }
	
	--	:modify{ id="prefix", visible=(s_export_type == "Strips"), enabled=true}

	end
	
local function RunProgram(data)
	
	UpdateDialog()
	
	if data.dir == "" then
		app.alert("No Directory chosen")
		dlg:close()
		end
	
	local path, file, extension = string.match(data.dir, "(.-)([^\\]-([^\\%.]+))$")
	
	file = file:match("(.+)%..+")
	if file == nil then file = ""
	else file = (file .. "_") 
		end
		
	extension = "." .. extension
		 
	local export_tag_list
	if s_export_tag == "All Tags" then 
		export_tag_list = s.tags
	else
		for i,tag in ipairs(s.tags) do
			if s_export_tag == tag.name then export_tag_list = {tag} end
			end
		
		end
	 
	if s_export_type == "Strips" then 		--Strip Packing
		
		for i, tag in ipairs(export_tag_list) do
			
			local new_img
			
			if s_export_strip_type == "Horizontal" then new_img = Image(s.width*tag.frames, s.height)
			else new_img = Image(s.width, s.height*tag.frames) end
			
			for j = 0, tag.frames - 1 do
				
				if s_export_strip_type == "Horizontal" then 
					new_img:drawSprite(s, tag.fromFrame.frameNumber + j , Point(s.width*j, 0)  )
				else 
					new_img:drawSprite(s, tag.fromFrame.frameNumber + j , Point(0, s.height*j) )
				end
			
			end

			new_img:saveAs(path .. file .. tag.name .. "_strip" .. tag.frames .. extension)
		end
		
	return
		
	end
		
	if s_export_type == "Animation" then 	--Animation
		
		if gif_export then
			
			for i, tag in ipairs(export_tag_list) do
				
				local new_spr = Sprite(s.spec)
				local _layer = new_spr.layers[1]
			
				for j = 0, tag.frames - 1 do
				
					local new_img = Image(s.width, s.height)
					new_img:drawSprite(s, tag.fromFrame.frameNumber + j )
					
					local new_Frame = new_spr:newEmptyFrame()
					new_spr:newCel(_layer, new_Frame, new_img )
					
					end
				
				new_spr:deleteFrame(1)
				
				new_spr:saveAs(path .. file .. tag.name .. extension)
				new_spr:close()
				
			end
			
			--]]
			
		else
			
			for i, tag in ipairs(export_tag_list) do
				
				local new_spr = Sprite(s.spec)
				
				for m = 1, tag.frames do new_spr:newFrame() end
				new_spr:deleteFrame(1)
				
				for l, cur_Layer in ipairs(s.layers) do AddLayer(new_spr, tag, new_spr, cur_Layer) end
					
				new_spr:deleteLayer( new_spr.layers[1] )
					
				new_spr:saveAs(path .. file .. tag.name .. extension)
				new_spr:close()
				
				end
			
			--]]
		end
			
		return
			
	end
		
	if s_export_type == "Sprite Sheet" then --Sheet Packing
		
		local sheet_w = s.width
		local sheet_h = s.height * #export_tag_list
		
		for i, tag in ipairs(export_tag_list) do
			sheet_w = math.max(s.width * tag.frames, sheet_w)
			end
		
		local new_img = Image(sheet_w, sheet_h)
		
		for i, tag in ipairs(export_tag_list) do
			for j = 0, tag.frames - 1 do
				new_img:drawSprite(s, tag.fromFrame.frameNumber + j ,  Point(s.width*j, s.height * (i-1))  )
				end	
			end
			
		local img_filename = path .. file .. "sheet" .. extension
		new_img:saveAs(img_filename)
		app.open(img_filename)
		
		return
		end
	
	end

local function Main()

	dlg 
		:combobox{ id="d_export_tag",
			label="Tags", 
			options=tag_options, 
			onchange=function() UpdateDialog() end  
			}
		:combobox{ id="d_export_type",
			label="Export Type",
			options=export_options, 
			onchange=function() UpdateDialog() end 
			}
		:combobox{ id="d_export_strip_type", options=strip_options,}
		
		:file{ id="dir", 
			label="Select Directory", 
			title="Output File", 
			open=false, 
			save=true, 
			filename=s.filename, 
			entry=true, 
			filetypes=file_type_list, 
			onchange=function() UpdateDialog() end
			}
		--:entry(id = "prefix", label:"File Prefix", text="spr_")s
		
		--:check{ id="d_close", text="Close Files", selected=s_close}
		--:check{ id="d_save", text="Save Files", selected=s_save}

	--Warning Messages
		:label{ id="Warning_1", label="", text="Alert: GIFs can only be exported as an Animation"}
		:label{ id="Warning_2", label="", text="Alert: PNGs (and other formats) can not be exported as an Animation"}
		:label{ id="Note_1", label="", text = "Note: Animation Export is going to fill your recent files list."}
		
	--Footer Buttons
		:button{id="ok", 
			text="&Export", 
			onclick=function() RunProgram(dlg.data) dlg:close() end 
			}
		:button{text="&Cancel"}
		:show{wait=false}
		
	UpdateDialog(dlg)
	
	end

--Execute
Main()
