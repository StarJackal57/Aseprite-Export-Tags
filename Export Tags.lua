local s = app.activeSprite

local function SplitFilename(strFilename)
	-- Returns the Path, Filename, and Extension as 3 values
	return string.match(strFilename, "(.-)([^\\]-([^\\%.]+))$")
end

if not s then
  app.alert("There is no sprite to export")
  return
end

local d = Dialog("Export All Tags")
d:file{ id="dir",label="Select Directory",title="Sprite Prefix",open=false,save=true, filename="directory"}
-- :combobox{ id="file_type",label="File Type",option="File Type",options={ "png (Horizontal Strip)", "gif",} }
 :entry{ id="name",label="Sprite Prefix",text="output",focus=true }
 :button{ id="ok", text="&Export"}
 :button{ text="&Cancel" }
 :show()
 
local data = d.data
if not data.ok then return end

path,file,extension = SplitFilename(data.dir)

data.file_type = "png (Horizontal Strip)"

if data.file_type == "png (Horizontal Strip)" then
  for i, tag in ipairs(s.tags) do
    
      local fcount = tag.frames;
      local new_img = Image(s.width*fcount, s.height)
      
      for j = 0, fcount do
        local p = Point(s.width*j, 0);
        new_img:drawSprite(s, tag.fromFrame.frameNumber + j ,  p  )
      end
      
      new_img:saveAs(path .. data.name .. "_" .. tag.name .. "_strip" .. fcount .. ".png")
      
    end
end
  
if data.file_type == "gif" then
end
  
  app.refresh()