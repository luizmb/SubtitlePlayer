import Foundation

public enum LanguageId: String, RawRepresentable, Codable {
    case all = "all"
    case afar = "aar"
    case abkhazian = "abk"
    case achinese = "ace"
    case acoli = "ach"
    case adangme = "ada"
    case adyghé = "ady"
    case afroAsiatic = "afa"
    case afrihili = "afh"
    case afrikaans = "afr"
    case ainu = "ain"
    case akan = "aka"
    case akkadian = "akk"
    case albanian = "alb"
    case aleut = "ale"
    case algonquian = "alg"
    case southernAltai = "alt"
    case amharic = "amh"
    case englishOld = "ang"
    case apache = "apa"
    case arabic = "ara"
    case aramaic = "arc"
    case aragonese = "arg"
    case armenian = "arm"
    case araucanian = "arn"
    case arapaho = "arp"
    case artificial = "art"
    case arawak = "arw"
    case assamese = "asm"
    case asturian = "ast"
    case athapascan = "ath"
    case australian = "aus"
    case avaric = "ava"
    case avestan = "ave"
    case awadhi = "awa"
    case aymara = "aym"
    case azerbaijani = "aze"
    case banda = "bad"
    case bamileke = "bai"
    case bashkir = "bak"
    case baluchi = "bal"
    case bambara = "bam"
    case balinese = "ban"
    case basque = "baq"
    case basa = "bas"
    case baltic = "bat"
    case beja = "bej"
    case belarusian = "bel"
    case bemba = "bem"
    case bengali = "ben"
    case berber = "ber"
    case bhojpuri = "bho"
    case bihari = "bih"
    case bikol = "bik"
    case bini = "bin"
    case bislama = "bis"
    case siksika = "bla"
    case bantu = "bnt"
    case bosnian = "bos"
    case braj = "bra"
    case breton = "bre"
    case batakIndonesia = "btk"
    case buriat = "bua"
    case buginese = "bug"
    case bulgarian = "bul"
    case burmese = "bur"
    case blin = "byn"
    case caddo = "cad"
    case centralAmericanIndian = "cai"
    case carib = "car"
    case catalan = "cat"
    case caucasian = "cau"
    case cebuano = "ceb"
    case celtic = "cel"
    case chamorro = "cha"
    case chibcha = "chb"
    case chechen = "che"
    case chagatai = "chg"
    case chineseSimplified = "chi"
    case chuukese = "chk"
    case mari = "chm"
    case chinookJargon = "chn"
    case choctaw = "cho"
    case chipewyan = "chp"
    case cherokee = "chr"
    case churchSlavic = "chu"
    case chuvash = "chv"
    case cheyenne = "chy"
    case chamic = "cmc"
    case coptic = "cop"
    case cornish = "cor"
    case corsican = "cos"
    case creolesAndPidginsEnglishBased = "cpe"
    case creolesAndPidginsFrenchBased = "cpf"
    case creolesAndPidginsPortugueseBased = "cpp"
    case cree = "cre"
    case crimeanTatar = "crh"
    case creolesAndPidginsOther = "crp"
    case kashubian = "csb"
    case cushiticCouchitiques = "cus"
    case czech = "cze"
    case dakota = "dak"
    case danish = "dan"
    case dargwa = "dar"
    case dayak = "day"
    case delaware = "del"
    case slaveAthapascan = "den"
    case dogrib = "dgr"
    case dinka = "din"
    case divehi = "div"
    case dogri = "doi"
    case dravidian = "dra"
    case duala = "dua"
    case dutchMiddle = "dum"
    case dutch = "dut"
    case dyula = "dyu"
    case dzongkha = "dzo"
    case efik = "efi"
    case egyptianAncient = "egy"
    case ekajuk = "eka"
    case elamite = "elx"
    case english = "eng"
    case englishMiddle = "enm"
    case esperanto = "epo"
    case estonian = "est"
    case ewe = "ewe"
    case ewondo = "ewo"
    case fang = "fan"
    case faroese = "fao"
    case fanti = "fat"
    case fijian = "fij"
    case filipino = "fil"
    case finnish = "fin"
    case finnoUgrian = "fiu"
    case fon = "fon"
    case french = "fre"
    case frenchMiddle = "frm"
    case frenchOld = "fro"
    case frisian = "fry"
    case fulah = "ful"
    case friulian = "fur"
    case ga = "gaa"
    case gayo = "gay"
    case gbaya = "gba"
    case germanic = "gem"
    case georgian = "geo"
    case german = "ger"
    case geez = "gez"
    case gilbertese = "gil"
    case gaelic = "gla"
    case irish = "gle"
    case galician = "glg"
    case manx = "glv"
    case germanMiddleHigh = "gmh"
    case germanOldHigh = "goh"
    case gondi = "gon"
    case gorontalo = "gor"
    case gothic = "got"
    case grebo = "grb"
    case greekAncient = "grc"
    case greek = "ell"
    case guarani = "grn"
    case gujarati = "guj"
    case gwich´in = "gwi"
    case haida = "hai"
    case haitian = "hat"
    case hausa = "hau"
    case hawaiian = "haw"
    case hebrew = "heb"
    case herero = "her"
    case hiligaynon = "hil"
    case himachali = "him"
    case hindi = "hin"
    case hittite = "hit"
    case hmong = "hmn"
    case hiriMotu = "hmo"
    case croatian = "hrv"
    case hungarian = "hun"
    case hupa = "hup"
    case iban = "iba"
    case igbo = "ibo"
    case icelandic = "ice"
    case ido = "ido"
    case sichuanYi = "iii"
    case ijo = "ijo"
    case inuktitut = "iku"
    case interlingue = "ile"
    case iloko = "ilo"
    case interlinguaInternationalAuxiliaryLanguageAsso = "ina"
    case indic = "inc"
    case indonesian = "ind"
    case indoEuropean = "ine"
    case ingush = "inh"
    case inupiaq = "ipk"
    case iranian = "ira"
    case iroquoian = "iro"
    case italian = "ita"
    case javanese = "jav"
    case japanese = "jpn"
    case judeoPersian = "jpr"
    case judeoArabic = "jrb"
    case karaKalpak = "kaa"
    case kabyle = "kab"
    case kachin = "kac"
    case kalaallisut = "kal"
    case kamba = "kam"
    case kannada = "kan"
    case karen = "kar"
    case kashmiri = "kas"
    case kanuri = "kau"
    case kawi = "kaw"
    case kazakh = "kaz"
    case kabardian = "kbd"
    case khasi = "kha"
    case khoisan = "khi"
    case khmer = "khm"
    case khotanese = "kho"
    case kikuyu = "kik"
    case kinyarwanda = "kin"
    case kirghiz = "kir"
    case kimbundu = "kmb"
    case konkani = "kok"
    case komi = "kom"
    case kongo = "kon"
    case korean = "kor"
    case kosraean = "kos"
    case kpelle = "kpe"
    case karachayBalkar = "krc"
    case kru = "kro"
    case kurukh = "kru"
    case kuanyama = "kua"
    case kumyk = "kum"
    case kurdish = "kur"
    case kutenai = "kut"
    case ladino = "lad"
    case lahnda = "lah"
    case lamba = "lam"
    case lao = "lao"
    case latin = "lat"
    case latvian = "lav"
    case lezghian = "lez"
    case limburgan = "lim"
    case lingala = "lin"
    case lithuanian = "lit"
    case mongo = "lol"
    case lozi = "loz"
    case luxembourgish = "ltz"
    case lubaLulua = "lua"
    case lubaKatanga = "lub"
    case ganda = "lug"
    case luiseno = "lui"
    case lunda = "lun"
    case luoKenyaAndTanzania = "luo"
    case lushai = "lus"
    case macedonian = "mac"
    case madurese = "mad"
    case magahi = "mag"
    case marshallese = "mah"
    case maithili = "mai"
    case makasar = "mak"
    case malayalam = "mal"
    case mandingo = "man"
    case maori = "mao"
    case austronesian = "map"
    case marathi = "mar"
    case masai = "mas"
    case malay = "may"
    case moksha = "mdf"
    case mandar = "mdr"
    case mende = "men"
    case irishMiddle = "mga"
    case mikmaq = "mic"
    case minangkabau = "min"
    case miscellaneous = "mis"
    case monKhmer = "mkh"
    case malagasy = "mlg"
    case maltese = "mlt"
    case manchu = "mnc"
    case manipuri = "mni"
    case manobo = "mno"
    case mohawk = "moh"
    case moldavian = "mol"
    case mongolian = "mon"
    case mossi = "mos"
    case mirandese = "mwl"
    case multipleLanguages = "mul"
    case munda = "mun"
    case creek = "mus"
    case marwari = "mwr"
    case mayan = "myn"
    case erzya = "myv"
    case nahuatl = "nah"
    case northAmericanIndian = "nai"
    case neapolitan = "nap"
    case nauru = "nau"
    case navajo = "nav"
    case ndebeleSouth = "nbl"
    case ndebeleNorth = "nde"
    case ndonga = "ndo"
    case lowGerman = "nds"
    case nepali = "nep"
    case nepalBhasa = "new"
    case nias = "nia"
    case nigerKordofanian = "nic"
    case niuean = "niu"
    case norwegianNynorsk = "nno"
    case norwegianBokmal = "nob"
    case nogai = "nog"
    case norse, Old = "non"
    case norwegian = "nor"
    case northernSotho = "nso"
    case nubian = "nub"
    case classicalNewari = "nwc"
    case chichewa = "nya"
    case nyamwezi = "nym"
    case nyankole = "nyn"
    case nyoro = "nyo"
    case nzima = "nzi"
    case occitan = "oci"
    case ojibwa = "oji"
    case oriya = "ori"
    case oromo = "orm"
    case osage = "osa"
    case ossetian = "oss"
    case turkishOttoman = "ota"
    case otomian = "oto"
    case papuan = "paa"
    case pangasinan = "pag"
    case pahlavi = "pal"
    case pampanga = "pam"
    case panjabi = "pan"
    case papiamento = "pap"
    case palauan = "pau"
    case persianOld = "peo"
    case persian = "per"
    case philippine = "phi"
    case phoenician = "phn"
    case pali = "pli"
    case polish = "pol"
    case pohnpeian = "pon"
    case portuguese = "por"
    case prakrit = "pra"
    case provençalOld = "pro"
    case pushto = "pus"
    case quechua = "que"
    case rajasthani = "raj"
    case rapanui = "rap"
    case rarotongan = "rar"
    case romance = "roa"
    case raetoRomance = "roh"
    case romany = "rom"
    case rundi = "run"
    case aromanian = "rup"
    case russian = "rus"
    case sandawe = "sad"
    case sango = "sag"
    case yakut = "sah"
    case southAmericanIndian = "sai"
    case salishan = "sal"
    case samaritanAramaic = "sam"
    case sanskrit = "san"
    case sasak = "sas"
    case santali = "sat"
    case serbian = "scc"
    case sicilian = "scn"
    case scots = "sco"
    case selkup = "sel"
    case semitic = "sem"
    case irishOld = "sga"
    case signLanguages = "sgn"
    case shan = "shn"
    case sidamo = "sid"
    case sinhalese = "sin"
    case siouan = "sio"
    case sinoTibetan = "sit"
    case slavic = "sla"
    case slovak = "slo"
    case slovenian = "slv"
    case southernSami = "sma"
    case northernSami = "sme"
    case sami = "smi"
    case luleSami = "smj"
    case inariSami = "smn"
    case samoan = "smo"
    case skoltSami = "sms"
    case shona = "sna"
    case sindhi = "snd"
    case soninke = "snk"
    case sogdian = "sog"
    case somali = "som"
    case songhai = "son"
    case sothoSouthern = "sot"
    case spanish = "spa"
    case sardinian = "srd"
    case serer = "srr"
    case niloSaharan = "ssa"
    case swati = "ssw"
    case sukuma = "suk"
    case sundanese = "sun"
    case susu = "sus"
    case sumerian = "sux"
    case swahili = "swa"
    case swedish = "swe"
    case syriac = "syr"
    case tahitian = "tah"
    case tai = "tai"
    case tamil = "tam"
    case tatar = "tat"
    case telugu = "tel"
    case timne = "tem"
    case tereno = "ter"
    case tetum = "tet"
    case tajik = "tgk"
    case tagalog = "tgl"
    case thai = "tha"
    case tibetan = "tib"
    case tigre = "tig"
    case tigrinya = "tir"
    case tiv = "tiv"
    case tokelau = "tkl"
    case klingon = "tlh"
    case tlingit = "tli"
    case tamashek = "tmh"
    case tongaNyasa = "tog"
    case tongaTongaIslands = "ton"
    case tokPisin = "tpi"
    case tsimshian = "tsi"
    case tswana = "tsn"
    case tsonga = "tso"
    case turkmen = "tuk"
    case tumbuka = "tum"
    case tupi = "tup"
    case turkish = "tur"
    case altaic = "tut"
    case tuvalu = "tvl"
    case twi = "twi"
    case tuvinian = "tyv"
    case udmurt = "udm"
    case ugaritic = "uga"
    case uighur = "uig"
    case ukrainian = "ukr"
    case umbundu = "umb"
    case undetermined = "und"
    case urdu = "urd"
    case uzbek = "uzb"
    case vai = "vai"
    case venda = "ven"
    case vietnamese = "vie"
    case volapük = "vol"
    case votic = "vot"
    case wakashan = "wak"
    case walamo = "wal"
    case waray = "war"
    case washo = "was"
    case welsh = "wel"
    case sorbian = "wen"
    case walloon = "wln"
    case wolof = "wol"
    case kalmyk = "xal"
    case xhosa = "xho"
    case yao = "yao"
    case yapese = "yap"
    case yiddish = "yid"
    case yoruba = "yor"
    case yupik = "ypk"
    case zapotec = "zap"
    case zenaga = "zen"
    case zhuang = "zha"
    case zande = "znd"
    case zulu = "zul"
    case zuni = "zun"
    case romanian = "rum"
    case portugueseBrazil = "pob"
    case montenegrin = "mne"
    case chineseTraditional = "zht"
    case chineseBilingual = "zhe"
    case portugueseMozambique = "pom"
    case extremaduran = "ext"
}

/*
http://www.opensubtitles.org/addons/export_languages.php
IdSubLanguage	ISO639	LanguageName	UploadEnabled	WebEnabled
aar	aa	Afar, afar	0	0
abk	ab	Abkhazian	0	0
ace		Achinese	0	0
ach		Acoli	0	0
ada		Adangme	0	0
ady		adyghé	0	0
afa		Afro-Asiatic (Other)	0	0
afh		Afrihili	0	0
afr	af	Afrikaans	1	0
ain		Ainu	0	0
aka	ak	Akan	0	0
akk		Akkadian	0	0
alb	sq	Albanian	1	1
ale		Aleut	0	0
alg		Algonquian languages	0	0
alt		Southern Altai	0	0
amh	am	Amharic	0	0
ang		English, Old (ca.450-1100)	0	0
apa		Apache languages	0	0
ara	ar	Arabic	1	1
arc		Aramaic	0	0
arg	an	Aragonese	1	1
arm	hy	Armenian	1	1
arn		Araucanian	0	0
arp		Arapaho	0	0
art		Artificial (Other)	0	0
arw		Arawak	0	0
asm	as	Assamese	0	0
ast	at	Asturian	1	1
ath		Athapascan languages	0	0
aus		Australian languages	0	0
ava	av	Avaric	0	0
ave	ae	Avestan	0	0
awa		Awadhi	0	0
aym	ay	Aymara	0	0
aze	az	Azerbaijani	1	0
bad		Banda	0	0
bai		Bamileke languages	0	0
bak	ba	Bashkir	0	0
bal		Baluchi	0	0
bam	bm	Bambara	0	0
ban		Balinese	0	0
baq	eu	Basque	1	1
bas		Basa	0	0
bat		Baltic (Other)	0	0
bej		Beja	0	0
bel	be	Belarusian	1	0
bem		Bemba	0	0
ben	bn	Bengali	1	0
ber		Berber (Other)	0	0
bho		Bhojpuri	0	0
bih	bh	Bihari	0	0
bik		Bikol	0	0
bin		Bini	0	0
bis	bi	Bislama	0	0
bla		Siksika	0	0
bnt		Bantu (Other)	0	0
bos	bs	Bosnian	1	0
bra		Braj	0	0
bre	br	Breton	1	1
btk		Batak (Indonesia)	0	0
bua		Buriat	0	0
bug		Buginese	0	0
bul	bg	Bulgarian	1	1
bur	my	Burmese	1	0
byn		Blin	0	0
cad		Caddo	0	0
cai		Central American Indian (Other)	0	0
car		Carib	0	0
cat	ca	Catalan	1	1
cau		Caucasian (Other)	0	0
ceb		Cebuano	0	0
cel		Celtic (Other)	0	0
cha	ch	Chamorro	0	0
chb		Chibcha	0	0
che	ce	Chechen	0	0
chg		Chagatai	0	0
chi	zh	Chinese (simplified)	1	1
chk		Chuukese	0	0
chm		Mari	0	0
chn		Chinook jargon	0	0
cho		Choctaw	0	0
chp		Chipewyan	0	0
chr		Cherokee	0	0
chu	cu	Church Slavic	0	0
chv	cv	Chuvash	0	0
chy		Cheyenne	0	0
cmc		Chamic languages	0	0
cop		Coptic	0	0
cor	kw	Cornish	0	0
cos	co	Corsican	0	0
cpe		Creoles and pidgins, English based (Other)	0	0
cpf		Creoles and pidgins, French-based (Other)	0	0
cpp		Creoles and pidgins, Portuguese-based (Other)	0	0
cre	cr	Cree	0	0
crh		Crimean Tatar	0	0
crp		Creoles and pidgins (Other)	0	0
csb		Kashubian	0	0
cus		Cushitic (Other)' couchitiques, autres langues	0	0
cze	cs	Czech	1	1
dak		Dakota	0	0
dan	da	Danish	1	1
dar		Dargwa	0	0
day		Dayak	0	0
del		Delaware	0	0
den		Slave (Athapascan)	0	0
dgr		Dogrib	0	0
din		Dinka	0	0
div	dv	Divehi	0	0
doi		Dogri	0	0
dra		Dravidian (Other)	0	0
dua		Duala	0	0
dum		Dutch, Middle (ca.1050-1350)	0	0
dut	nl	Dutch	1	1
dyu		Dyula	0	0
dzo	dz	Dzongkha	0	0
efi		Efik	0	0
egy		Egyptian (Ancient)	0	0
eka		Ekajuk	0	0
elx		Elamite	0	0
eng	en	English	1	1
enm		English, Middle (1100-1500)	0	0
epo	eo	Esperanto	1	1
est	et	Estonian	1	1
ewe	ee	Ewe	0	0
ewo		Ewondo	0	0
fan		Fang	0	0
fao	fo	Faroese	0	0
fat		Fanti	0	0
fij	fj	Fijian	0	0
fil		Filipino	0	0
fin	fi	Finnish	1	1
fiu		Finno-Ugrian (Other)	0	0
fon		Fon	0	0
fre	fr	French	1	1
frm		French, Middle (ca.1400-1600)	0	0
fro		French, Old (842-ca.1400)	0	0
fry	fy	Frisian	0	0
ful	ff	Fulah	0	0
fur		Friulian	0	0
gaa		Ga	0	0
gay		Gayo	0	0
gba		Gbaya	0	0
gem		Germanic (Other)	0	0
geo	ka	Georgian	1	1
ger	de	German	1	1
gez		Geez	0	0
gil		Gilbertese	0	0
gla	gd	Gaelic	1	0
gle	ga	Irish	1	0
glg	gl	Galician	1	1
glv	gv	Manx	0	0
gmh		German, Middle High (ca.1050-1500)	0	0
goh		German, Old High (ca.750-1050)	0	0
gon		Gondi	0	0
gor		Gorontalo	0	0
got		Gothic	0	0
grb		Grebo	0	0
grc		Greek, Ancient (to 1453)	0	0
ell	el	Greek	1	1
grn	gn	Guarani	0	0
guj	gu	Gujarati	0	0
gwi		Gwich´in	0	0
hai		Haida	0	0
hat	ht	Haitian	0	0
hau	ha	Hausa	0	0
haw		Hawaiian	0	0
heb	he	Hebrew	1	1
her	hz	Herero	0	0
hil		Hiligaynon	0	0
him		Himachali	0	0
hin	hi	Hindi	1	1
hit		Hittite	0	0
hmn		Hmong	0	0
hmo	ho	Hiri Motu	0	0
hrv	hr	Croatian	1	1
hun	hu	Hungarian	1	1
hup		Hupa	0	0
iba		Iban	0	0
ibo	ig	Igbo	0	0
ice	is	Icelandic	1	1
ido	io	Ido	0	0
iii	ii	Sichuan Yi	0	0
ijo		Ijo	0	0
iku	iu	Inuktitut	0	0
ile	ie	Interlingue	0	0
ilo		Iloko	0	0
ina	ia	Interlingua (International Auxiliary Language Asso	0	0
inc		Indic (Other)	0	0
ind	id	Indonesian	1	1
ine		Indo-European (Other)	0	0
inh		Ingush	0	0
ipk	ik	Inupiaq	0	0
ira		Iranian (Other)	0	0
iro		Iroquoian languages	0	0
ita	it	Italian	1	1
jav	jv	Javanese	0	0
jpn	ja	Japanese	1	1
jpr		Judeo-Persian	0	0
jrb		Judeo-Arabic	0	0
kaa		Kara-Kalpak	0	0
kab		Kabyle	0	0
kac		Kachin	0	0
kal	kl	Kalaallisut	0	0
kam		Kamba	0	0
kan	kn	Kannada	1	0
kar		Karen	0	0
kas	ks	Kashmiri	0	0
kau	kr	Kanuri	0	0
kaw		Kawi	0	0
kaz	kk	Kazakh	1	0
kbd		Kabardian	0	0
kha		Khasi	0	0
khi		Khoisan (Other)	0	0
khm	km	Khmer	1	1
kho		Khotanese	0	0
kik	ki	Kikuyu	0	0
kin	rw	Kinyarwanda	0	0
kir	ky	Kirghiz	0	0
kmb		Kimbundu	0	0
kok		Konkani	0	0
kom	kv	Komi	0	0
kon	kg	Kongo	0	0
kor	ko	Korean	1	1
kos		Kosraean	0	0
kpe		Kpelle	0	0
krc		Karachay-Balkar	0	0
kro		Kru	0	0
kru		Kurukh	0	0
kua	kj	Kuanyama	0	0
kum		Kumyk	0	0
kur	ku	Kurdish	1	0
kut		Kutenai	0	0
lad		Ladino	0	0
lah		Lahnda	0	0
lam		Lamba	0	0
lao	lo	Lao	0	0
lat	la	Latin	0	0
lav	lv	Latvian	1	0
lez		Lezghian	0	0
lim	li	Limburgan	0	0
lin	ln	Lingala	0	0
lit	lt	Lithuanian	1	0
lol		Mongo	0	0
loz		Lozi	0	0
ltz	lb	Luxembourgish	1	0
lua		Luba-Lulua	0	0
lub	lu	Luba-Katanga	0	0
lug	lg	Ganda	0	0
lui		Luiseno	0	0
lun		Lunda	0	0
luo		Luo (Kenya and Tanzania)	0	0
lus		lushai	0	0
mac	mk	Macedonian	1	1
mad		Madurese	0	0
mag		Magahi	0	0
mah	mh	Marshallese	0	0
mai		Maithili	0	0
mak		Makasar	0	0
mal	ml	Malayalam	1	0
man		Mandingo	0	0
mao	mi	Maori	0	0
map		Austronesian (Other)	0	0
mar	mr	Marathi	0	0
mas		Masai	0	0
may	ms	Malay	1	1
mdf		Moksha	0	0
mdr		Mandar	0	0
men		Mende	0	0
mga		Irish, Middle (900-1200)	0	0
mic		Mi'kmaq	0	0
min		Minangkabau	0	0
mis		Miscellaneous languages	0	0
mkh		Mon-Khmer (Other)	0	0
mlg	mg	Malagasy	0	0
mlt	mt	Maltese	0	0
mnc		Manchu	0	0
mni	ma	Manipuri	1	0
mno		Manobo languages	0	0
moh		Mohawk	0	0
mol	mo	Moldavian	0	0
mon	mn	Mongolian	1	0
mos		Mossi	0	0
mwl		Mirandese	0	0
mul		Multiple languages	0	0
mun		Munda languages	0	0
mus		Creek	0	0
mwr		Marwari	0	0
myn		Mayan languages	0	0
myv		Erzya	0	0
nah		Nahuatl	0	0
nai		North American Indian	0	0
nap		Neapolitan	0	0
nau	na	Nauru	0	0
nav	nv	Navajo	0	0
nbl	nr	Ndebele, South	0	0
nde	nd	Ndebele, North	0	0
ndo	ng	Ndonga	0	0
nds		Low German	0	0
nep	ne	Nepali	0	0
new		Nepal Bhasa	0	0
nia		Nias	0	0
nic		Niger-Kordofanian (Other)	0	0
niu		Niuean	0	0
nno	nn	Norwegian Nynorsk	0	0
nob	nb	Norwegian Bokmal	0	0
nog		Nogai	0	0
non		Norse, Old	0	0
nor	no	Norwegian	1	1
nso		Northern Sotho	0	0
nub		Nubian languages	0	0
nwc		Classical Newari	0	0
nya	ny	Chichewa	0	0
nym		Nyamwezi	0	0
nyn		Nyankole	0	0
nyo		Nyoro	0	0
nzi		Nzima	0	0
oci	oc	Occitan	1	1
oji	oj	Ojibwa	0	0
ori	or	Oriya	0	0
orm	om	Oromo	0	0
osa		Osage	0	0
oss	os	Ossetian	0	0
ota		Turkish, Ottoman (1500-1928)	0	0
oto		Otomian languages	0	0
paa		Papuan (Other)	0	0
pag		Pangasinan	0	0
pal		Pahlavi	0	0
pam		Pampanga	0	0
pan	pa	Panjabi	0	0
pap		Papiamento	0	0
pau		Palauan	0	0
peo		Persian, Old (ca.600-400 B.C.)	0	0
per	fa	Persian	1	1
phi		Philippine (Other)	0	0
phn		Phoenician	0	0
pli	pi	Pali	0	0
pol	pl	Polish	1	1
pon		Pohnpeian	0	0
por	pt	Portuguese	1	1
pra		Prakrit languages	0	0
pro		Provençal, Old (to 1500)	0	0
pus	ps	Pushto	0	0
que	qu	Quechua	0	0
raj		Rajasthani	0	0
rap		Rapanui	0	0
rar		Rarotongan	0	0
roa		Romance (Other)	0	0
roh	rm	Raeto-Romance	0	0
rom		Romany	0	0
run	rn	Rundi	0	0
rup		Aromanian	0	0
rus	ru	Russian	1	1
sad		Sandawe	0	0
sag	sg	Sango	0	0
sah		Yakut	0	0
sai		South American Indian (Other)	0	0
sal		Salishan languages	0	0
sam		Samaritan Aramaic	0	0
san	sa	Sanskrit	0	0
sas		Sasak	0	0
sat		Santali	0	0
scc	sr	Serbian	1	1
scn		Sicilian	0	0
sco		Scots	0	0
sel		Selkup	0	0
sem		Semitic (Other)	0	0
sga		Irish, Old (to 900)	0	0
sgn		Sign Languages	0	0
shn		Shan	0	0
sid		Sidamo	0	0
sin	si	Sinhalese	1	1
sio		Siouan languages	0	0
sit		Sino-Tibetan (Other)	0	0
sla		Slavic (Other)	0	0
slo	sk	Slovak	1	1
slv	sl	Slovenian	1	1
sma		Southern Sami	0	0
sme	se	Northern Sami	1	0
smi		Sami languages (Other)	0	0
smj		Lule Sami	0	0
smn		Inari Sami	0	0
smo	sm	Samoan	0	0
sms		Skolt Sami	0	0
sna	sn	Shona	0	0
snd	sd	Sindhi	1	0
snk		Soninke	0	0
sog		Sogdian	0	0
som	so	Somali	0	0
son		Songhai	0	0
sot	st	Sotho, Southern	0	0
spa	es	Spanish	1	1
srd	sc	Sardinian	0	0
srr		Serer	0	0
ssa		Nilo-Saharan (Other)	0	0
ssw	ss	Swati	0	0
suk		Sukuma	0	0
sun	su	Sundanese	0	0
sus		Susu	0	0
sux		Sumerian	0	0
swa	sw	Swahili	1	0
swe	sv	Swedish	1	1
syr	sy	Syriac	1	0
tah	ty	Tahitian	0	0
tai		Tai (Other)	0	0
tam	ta	Tamil	1	0
tat	tt	Tatar	0	0
tel	te	Telugu	1	0
tem		Timne	0	0
ter		Tereno	0	0
tet		Tetum	0	0
tgk	tg	Tajik	0	0
tgl	tl	Tagalog	1	1
tha	th	Thai	1	1
tib	bo	Tibetan	0	0
tig		Tigre	0	0
tir	ti	Tigrinya	0	0
tiv		Tiv	0	0
tkl		Tokelau	0	0
tlh		Klingon	0	0
tli		Tlingit	0	0
tmh		Tamashek	0	0
tog		Tonga (Nyasa)	0	0
ton	to	Tonga (Tonga Islands)	0	0
tpi		Tok Pisin	0	0
tsi		Tsimshian	0	0
tsn	tn	Tswana	0	0
tso	ts	Tsonga	0	0
tuk	tk	Turkmen	0	0
tum		Tumbuka	0	0
tup		Tupi languages	0	0
tur	tr	Turkish	1	1
tut		Altaic (Other)	0	0
tvl		Tuvalu	0	0
twi	tw	Twi	0	0
tyv		Tuvinian	0	0
udm		Udmurt	0	0
uga		Ugaritic	0	0
uig	ug	Uighur	0	0
ukr	uk	Ukrainian	1	1
umb		Umbundu	0	0
und		Undetermined	0	0
urd	ur	Urdu	1	0
uzb	uz	Uzbek	0	1
vai		Vai	0	0
ven	ve	Venda	0	0
vie	vi	Vietnamese	1	1
vol	vo	Volapük	0	0
vot		Votic	0	0
wak		Wakashan languages	0	0
wal		Walamo	0	0
war		Waray	0	0
was		Washo	0	0
wel	cy	Welsh	0	0
wen		Sorbian languages	0	0
wln	wa	Walloon	0	0
wol	wo	Wolof	0	0
xal		Kalmyk	0	0
xho	xh	Xhosa	0	0
yao		Yao	0	0
yap		Yapese	0	0
yid	yi	Yiddish	0	0
yor	yo	Yoruba	0	0
ypk		Yupik languages	0	0
zap		Zapotec	0	0
zen		Zenaga	0	0
zha	za	Zhuang	0	0
znd		Zande	0	0
zul	zu	Zulu	0	0
zun		Zuni	0	0
rum	ro	Romanian	1	1
pob	pb	Portuguese (BR)	1	1
mne	me	Montenegrin	1	0
zht	zt	Chinese (traditional)	1	1
zhe	ze	Chinese bilingual	1	0
pom	pm	Portuguese (MZ)	1	0
ext	ex	Extremaduran	1	0
 */


