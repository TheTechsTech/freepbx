<?php
/**
 * AvantFAX - "Web 2.0" HylaFAX management
 *
 * PHP 5 only
 *
 * @author		David Mimms <david@avantfax.com>
 * @copyright	2005 - 2007 MENTALBARCODE Software, LLC
 * @copyright	2007 - 2008 iFAX Solutions, Inc.
 * @license		http://www.gnu.org/copyleft/gpl.html GNU/GPL
 */

	//
	//	DATABASE SETTINGS
	//
	// EDIT DATABASE USER INFO
	// You must create the database before you continue (mysql -p < create_table.sql)
	define('AFDB_USER',		'root');	// username
	define('AFDB_PASS',		'CLEARTEXT_PASSWORD');		// password
	define('AFDB_NAME',		'avantfax');	// database name
	define('AFDB_ENGINE',	'mysql');		// database engine: mysql
	define('AFDB_HOST',		'localhost');	// database host

	//
	//	HYLAFAX SETTINGS
	//
	$BINARYDIR			= '/usr/bin';		// typical on Linux, while /usr/local/bin would be typical for FreeBSD
	$HYLAFAX_PREFIX		= '/usr';			// if you installed hylafax from source, your installation may default to /usr/local
	$HYLASPOOL			= '/var/spool/hylafax';

	// Use HylaFAX's tiff2ps script (/var/spool/hylafax/bin/tiff2ps) instead of AvantFAX's tiff2ps functionality
	$HYLATIFF2PS		= false;


	//
	//	Configuring Caller ID
	//
	// Set the following to resemble the order in which your Caller ID information and DID/DNIS/DTMF information is stored in your TIFF fax file
	// Example output from 'faxinfo fax0000000XX.tif'
	//	Sender: Internal Fax
	//	CallID1: 8005551212
	//	CallID2: iFAX
	//	CallID3: 8490
	//
	// The config.<devid> file has these settings set:
	//	CallIDPattern:    "NMBR="
	//	CallIDPattern:    "NAME="
	//	CallIDPattern:    "NDID="
	//
	$CALLIDn_CIDNumber	= 1;
	$CALLIDn_CIDName	= 2;
	$CALLIDn_DIDNum		= 3;

	//
	//	Faxmail user
	//
	// If you're using Email to FAX through your MTA, set the following value as the faxmail user you chose
	// If you're using postfix on Debian, this may be faxmaster
	$FAXMAILUSER		= 'faxmail';

	//
	//	Apache user
	//
	// When resubmitting a fax job (faxalter -r), the fax job shows up as owned by the user running httpd
	// In order to properly lookup the correct user, $WWWUSER must be the name of the user running httpd.
	// Examples are apache, www-run, nobody
	$WWWUSER			= 'asterisk';

	//
	//	AvantFAX System email address
	//
	// Emails from faxrcvd and notify are sent from this email address
	define('ADMIN_EMAIL', 'root@localhost');	// system return email address

	//
	//	EMAIL settings for faxrcvd and notify
	//
	// If you would like to include the fax PDF for successful faxes, set the following to true
	// Failed faxes automatically have the failed PDF attached to the email
	$NOTIFY_INCLUDE_PDF = false;

	// If you would like the email from faxrcvd to include the thumbnail image
	$FAXRCVD_INCLUDE_THUMBNAIL = true;
	$FAXRCVD_INCLUDE_PDF = true;

	//
	//	DID/DTMF Routing
	//
	// If you're using DTMF enabled hardware or PBX that is sending hunt group information to HylaFAX, you can set the following to true
	$ENABLE_DID_ROUTING	= false;

	// Set this to false if you don't want to auto configure new DID/DTMF Routing groups.  This is helpful for automatically creating
	// new DID groups upon receiving new faxes.  However, some may find it a hassle to have new groups created.  Faxes that arrive
	// on an unconfigured DID/DTMF group will then go into the Catch-All group
	$AUTOCONFDID		= true;

	//
	//	AvantFAX Interface Options
	//

	$dft_config_lang	= 'en';		// default system language (english)

	// Default values for fields when sending a fax either through AvantFAX or directly through HylaFAX
	// (only if they haven't been set in /etc/hylafax/hyla.conf)
	$FROM_COMPANY		= "";
	$FROM_LOCATION		= "";
	$FROM_FAXNUMBER		= "";
	$FROM_VOICENUMBER	= "";
	$DEFAULT_TSI_ID		= "";

	// enable interface to show link for downloading the original TIFF file
	$ENABLE_DL_TIFF		= false;

	// server name
	$AVANTFAX_SERVERNAME	= 'avantfax'; // replace with a custom string for your server name, otherwise leave NULL to use your server's hostname (if found)
	$SHOWSERVER_DETAILS		= false;

	// Show all Address book contacts
	// You would set to false once you have several hundreds (even thousands) of contacts that it doesn't make sense
	// to load them all every time you load a page like Contacts and Archive
	$SHOW_ALL_CONTACTS 	= true;

	// If you want to convert your faxes to G4 format (to save space) when faxrcvd copies the tif file to the AvantFAX archive
	$TIFF_TO_G4			= false;

	// To enable debugging
	$AVANTFAX_DEBUG		= false;

	// This mode is for restricting user access to faxes in the archive
	// When diabled, users can view faxes that were received on their viewable fax line (or DID group) OR viewable category
	// When enabled, users can only view faxes that were received on their viewable fax line (or DID group) AND viewable category
	// Therefore, when in use, users who have access to one modem (or DID group) cannot see the faxes from another modem (or DID group)
	// even if they can view that category
	define('RESTRICTED_USER_MODE', false);

	// set to 1 if you want your custom cover page to show total pages in the fax instead of number pages that follow the cover page
	// this is used ONLY when you send a fax that consists of just the cover page
	// the default cover page displays (Number of pages to follow: 0)
	$NUM_PAGES_FOLLOW	= 0;

	// Fax number lookup
	// replace your own link but fax number must be behind the last =
	define('WHITEPAGES', "http://www.whitepages.com/search/ReversePhone?full_phone="); // White Pages USA
//	define('WHITEPAGES', "http://www.paginebianche.it/execute.cgi?btt=1&tl=2&tr=106&qs="); // White Pages Italy
//	define('WHITEPAGES', "http://privatpersoner.eniro.se/query?stq=0&searcharea=&what=wphone&searchword="); // Vita sidorna Eniro, Sverige

	// increase if you want users to be able to have longer values
	// WHFC has issues with usernames longer than 15 chars
	define('MAX_USERNAME_SIZE',		15);
	define('MAX_PASSWD_SIZE',		15);
	define('MIN_PASSWD_SIZE',		8);
	define('MAX_EMAIL_SIZE',		99);

	// List Inbox by modem instead of by date
	define('INBOX_LIST_MODEM', false);

	// Inbox takes focus when new fax arrives
	$FOCUS_ON_NEW_FAX		= false;
	// Inbox shows a popup window (Javascript alert) when a new fax arrives
	$FOCUS_ON_NEW_FAX_POPUP	= false;

	// Default setting for requesting "requeued" email
	$SENDFAX_REQUEUE_EMAIL	= true;

	// Toggle if you want to show the Cover page form in sendfax.php (set: true or false)
	$SENDFAX_USE_COVERPAGE	= true;

	// Archive faxes "Routed by Sender"
	// if you would like to see all faxes that are "Routed by Sender" in your Inbox, then set this to false.
	// Otherwise, set this to true, so that the fax is archived
	$ARCHIVEFAX2EMAIL		= true;

	// For smaller screens (ie: 1024x768), set this to false
	// When set to false, the Archve page will fit the fax preview image in with the rest of the results
	$ARCHIVE_WIDE			= true;

	// Set the default number of faxes to display per page in the Inbox and Archive (if user hasn't specified a preference)
	// Use either: 10, 15, 20, 25, 30, 50, or 100
	$DEFAULT_FAXES_PER_PAGE_INBOX = 25;
	$DEFAULT_FAXES_PER_PAGE_ARCHIVE = 30;

	//
	//	OCR Support
	//
	// Enable support for Tesseract to read the content of your fax and store the data in your database for improved Archive searching
	// tesseract must be installed first
	define('ENABLE_OCR_SUPPORT',	false); // set to true to enable support
	define('OCR_BINARY',			"/usr/local/bin/tesseract");
	define('OCR_COMMAND', 			OCR_BINARY." %s %s -l %s"); // to use all languages, remove "-l %s" from the command
	define('OCR_LANGUAGE',			"eng"); // Examples: eng, fra, deu, spa, ita

	//
	//	Barcode Support
	//
	// If you have the bardecode software, you can enable this functionality to automatically store any barcode data from received faxes in the database
	// Contact sales@ifax.com for details
	define('ENABLE_BARDECODE_SUPPORT', false);
	define('BARDECODE_BINARY',		"/var/spool/hylafax/bin/bardecode");
	define('BARDECODE_COMMAND', 	BARDECODE_BINARY." -t any -f %s");

	//
	//	Annotation support
	//
	// If you want to annotate each fax with AvantFAX's faxid
	define('ENABLE_FAX_ANNOTATION', false);
	define('ANN_GRAVITY', 'south'); // acceptable values: north, northeast, northwest, south, southeast, southwest
	// If you want to print the annotated PDF, set the following to true.  Otherwise, the received TIFF file will be printed as received (not annotated)
	$FAXRCVD_PRINT_PDF	= false;

	//
	//	Email settings
	//
	// Email encoding options (values are: SevenBitEncoding, QPrintEncoding, Base64Encoding)
	define('EMAIL_ENCODING_TEXT', "Base64Encoding");
	define('EMAIL_ENCODING_HTML', "Base64Encoding");

	// Email Charset options (values: UTF-8, or whatever your iso-8859 charset is)
	define('EMAIL_ENCODING_CHARSET', "UTF-8");

	// SMTP server support for using external mail server (mail server not on this machine)
	define('USE_SMTPSERVER',	false);			// set to true to enable usage
	define('SMTP_SERVER',		'localhost');	// set your mail server address (ie: mail.example.com, or ssl://mail.example.com)
	define('SMTP_PORT',			25);			// mail server port.  For SSL, try 465
	define('SMTP_AUTH',			false);			// set to true to enable SMTP authentication
	define('SMTP_USERNAME',		'');			// username for authentication
	define('SMTP_PASSWORD',		'');			// password for authentication
	define('SMTP_LOCALHOST',	'localhost');	// the value to give for HELO

	// If you do want to receive an email for every successful sent fax, set $NOTIFY_ON_SUCCESS = true
	// If you don't want to receive an email, set it the following to false.  This is a global setting and
	// individual users cannot override it.
	$NOTIFY_ON_SUCCESS = true;

	// AvantFAX Email signature
	$SYSTEM_EMAIL_SIG_HTML	= '<a href="http://www.avantfax.com/">AvantFAX</a>';
	$SYSTEM_EMAIL_SIG_TEXT	= 'www.AvantFAX.com';

	//
	//	Cover page
	//
	// This is the path to your custom cover page
	// The PostScript file must be located in the images/ directory
	$COVERPAGE_FILE			= 'cover.ps'; // ie: mycover.ps, coverpage.html

	// The new cover page feature allows you to use an HTML page as your cover page
	// This means that it will be much easier to make your own coverpages to be used with AvantFAX/HylaFAX
	// Your custom HTML cover page must be located in AvantFAX's "images" directory
	// This feature requires html2ps.  AvantFAX was tested with version 1.0 beta5
	// To download html2ps, follow this URL: http://user.it.uu.se/~jan/html2ps.html
	$HTML2PS				= '/usr/local/bin/html2ps';	// path to html2ps

	// if you need to change the document size
	$PAPERSIZE				= 'letter'; // a4, letter

	// Cover Page options (for postscript cover pages)
	$CPAGE_LINELEN			= 80;  // max line length

	//
	//	Printer Settings
	//
	// Printing support for received faxes to enable support, change to true
	$PRINTFAXRCVD			= false;
	$PRINTERNAME			= '';					// the name of the print queue or leave blank for default printer
	$PRINTCMD				= '/usr/bin/lpr';		// the print spool command
	$PRINTFAX2PS			= '/usr/bin/fax2ps';	// the print command
	$PDFPRINTCMD			= '/usr/bin/lpr';		// the print command for PDFs

	//
	//	Date format settings
	//
	define('FAXCOVER_DATE_FORMAT',	"%d.%m.%Y %H:%M");	// strftime format for faxcover. Example: "%m/%d/%Y %H:%M"
	define('EMAIL_DATE_FORMAT',		"%d.%m.%Y %H:%M");	// strftime format for notify/faxrcvd subject email dates. Example: "%m/%d/%Y %H:%M"
	define('ARCHIVE_DATE_FORMAT',	"'%d.%m.%Y %H:%i'");// SQL format for Inbox & Archive Dates.  Example: "'%m/%d/%Y %H:%i'" or "GET_FORMAT(DATETIME, 'USA')"

	//
	//	Ghostscript tweaks
	//
	// ghostscript
	$DPI	= 92;	// DPI of recieved faxes viewed in inbox (calibrate for rotate speed) higher number for faster processor.  View AvantFAX Admin Logs for stats.
	$DPIS	= 200;	// DPI of sent faxes kept in archive (calibrate for pdf file size)

	define('PREV_TN', 80);		// thumbnail width
	define('PREV_SP', 750);		// view fax preview fax image width

	//
	//	Custom Authentication settings
	//
	// If you would like to use/develop your own custom authentication backend, set ALTERNATE_AUTH_ENABLE to true and see below
	$ALTERNATE_AUTH_ENABLE = false;
	// If you want to allow users who aren't able to login via your custom authentication method to be able to login using
	// their AvantFAX username and password, set ALTERNATE_AUTH_FALLBACK to true.  Otherwise, if you require all users to
	// login using your method, set ALTERNATE_AUTH_FALLBACK to false.
	$ALTERNATE_AUTH_FALLBACK = true;
	// Enter the name of your custom authentication class below.  The name of the class must be identical (case-sensitive)
	// to the PHP file name and the class must be located in the includes/ directory.  The class file will by dynamically
	// included by AvantFAX when needed.  Your class must implement the "CustomAuth" interface found in includes/classes.php.
	// For an example, see includes/PAMAuth.php
	$ALTERNATE_AUTH_CLASS = "PAMAuth";
