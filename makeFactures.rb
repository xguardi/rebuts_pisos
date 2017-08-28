# 
# Script per generar les factures per tots els pisos durant un any (12 factures)
# 
# requereix tenir instalÂ·lades les gemes
# gem install wkhtmltopdf-binary
# gem install pdfkit

require "rubygems"
gem "pdfkit"
require "pdfkit"
require "date"

def sanitize_filename(filename)
  filename.strip.tap do |name|
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # get only the filename, not the whole path
    name.sub! /\A.*(\\|\/)/, ''
    # Finally, replace all non alphanumeric, underscore
    # or periods with underscore
    name.gsub! /[^\w\.\-]/, '_'
  end
end

# classe Lloguer
class Lloguer
  attr_accessor :mes
  attr_accessor :any
  attr_accessor :propietari
  attr_accessor :nif_propietari
  attr_accessor :nif_llogater
  attr_accessor :adreca
  attr_accessor :pis
  attr_accessor :porta
  attr_accessor :llogater
  attr_accessor :renta
  attr_accessor :llum
  attr_accessor :llum_pis
  attr_accessor :escombraries
  attr_accessor :aigua
  attr_accessor :IRPF
  attr_accessor :IVA
  attr_accessor :subtotal
  attr_accessor :total
end

# script
puts "Llegim fitxer de dades..."
lloguers = []
dades = File.open("dades.csv").each do |line|
  l = Lloguer.new
  l.mes, l.any, l.propietari, l.nif_propietari, l.nif_llogater, l.adreca, l.pis, l.porta, l.llogater, l.renta, l.llum, l.llum_pis, l.escombraries, l.aigua, l.IRPF, l.IVA = line.split(';')
  lloguers << l
end

# Eliminem les capcaleres
lloguers.delete_at(0)

html = ""
html << "<html>"
html << "<head>"
html << "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=Windows-1252\">"
html << "</head>"
html << "<body>"

puts "Generem els PDF..."
i = 0
for l in lloguers

  i = i + 1 # comptador

  puts "Mes: " + l.mes 
  puts "Any:" + l.any
  puts "Propietari:" + l.propietari
  puts "NIF_prop:" + l.nif_propietari
  puts "Adreca:" + l.adreca
  puts "Pis:" + l.pis
  puts "Porta:" + l.porta
  puts "Llogater:" + l.llogater
  puts "Renta:" + l.renta
  puts "Llum:" + l.llum
  puts "Llum pid:" + l.llum_pis
  puts "Escombraries:" + l.escombraries
  puts "IRPF:" + l.IRPF
  puts "IVA:" + l.IVA

  puts "---"

  # càlculs
  l.subtotal = l.renta.to_f + l.llum.to_f + l.llum_pis.to_f + l.escombraries.to_f + l.aigua.to_f
  irpf = 0
  iva = 0
  if l.IRPF != ""
	  irpf = l.renta.to_f*(l.IRPF.to_f/100)
  end
  if l.IVA!= ""
	  iva = l.renta.to_f*(l.IVA.to_f/100)
  end
  l.total = l.subtotal.to_f - irpf.to_f + iva.to_f



  if (i % 2) == 0 
	  html << "<div class='rebut pagebreak'>"
  else
	  html << "<div class='rebut'>"
  end
  html << "<p class='left'>CASA PROPIETAT DE: <b>" + l.propietari + "</b></p>"
  html << "<p class='right'>DNI: <b>" + l.nif_propietari + "</b>&nbsp;</p>"
  html << "<div class='clear'></div>"
  html << "<div class='detall'>"
  html << "<table>"
  html << "<tr><td class='label'>Renta</td><td>" + l.renta + " &euro;</td></tr>"
  html << "<tr><td class='label'>Llum</td><td>" + l.llum + " &euro;</td></tr>"
  html << "<tr><td class='label'>Llum pis</td><td>" + l.llum_pis + " &euro;</td></tr>"
  html << "<tr><td class='label'>Escombraries</td><td>" + l.escombraries + " &euro;</td></tr>"
  html << "<tr><td class='label'>Aigua</td><td>" + l.aigua + " &euro;</td></tr>"
  html << "<tr><td></td><td>&nbsp;</td></tr>"
  html << "<tr><td class='label'>Subtotal</td><td>" + sprintf("%.2f", l.subtotal) + " &euro;</td></tr>"
  html << "<tr><td class='label'>IRPF</td><td>" + sprintf("%.2f", irpf) + " &euro;</td></tr>"
  html << "<tr><td class='label'>I.V.A.</td><td>" + sprintf("%.2f", iva) + " &euro;</td></tr>"
  html << "<tr><td class='label'>TOTAL</td><td>" + sprintf("%.2f", l.total) + " &euro;</td></tr>"
  html << "</table>"
  html << "</div>"
  html << "<div class='main'>"
  html << "<fieldset style='float:left;width:400px'><legend align='center'>Adre&ccedil;a</legend>" + l.adreca + "</fieldset>"
  html << "<fieldset style='float:left;width:50px'><legend align='center'>Pis</legend>" + l.pis + "</fieldset>"
  html << "<fieldset style='float:left;width:50px'><legend align='center'>Porta</legend>" + l.porta + "</fieldset>"
  html << "<div class='clear'></div>"
  html << "<fieldset style='width:400px'><legend align='center'>Data</legend>1 de " + l.mes + " del " + l.any + "</fieldset>"
  html << "<p>REBUT DE: <b>" + l.llogater + "</b><br/>NIF/CIF: " + l.nif_llogater + "</p>"
  html << "<p>La quantitat de <span>" + sprintf("%.2f", l.total) + " &euro;</span> de lloguer pel mes <span>" + l.mes + "</span> del local o vivenda en les condicions opotunes i expressament convingudes i acceptades.</p>"
  html << ""
  html << "<fieldset style='width:200px;background:#ccc;text-align:right;font-weight:bold;'><legend align='center'>Import total</legend>" + sprintf("%.2f", l.total) + " &euro;</fieldset>"
  html << "</div>"
  html << "<div class='clear'></div>"
  html << "</div>"

end

html << "</body></html>"
kit = PDFKit.new(html, :page_size => 'A4')
kit.stylesheets << 'rebut.css'
#filename = l.pis + l.porta + "_" + l.llogater + '.pdf'
#filename = sanitize_filename(filename)
#filename = 'rebuts/' + filename
file = kit.to_file("rebuts.pdf")

puts "Fet."


