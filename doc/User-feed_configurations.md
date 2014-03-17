## User proposed feed cnfigurations

##### User: joten (2014-03-17, owl-u 0.2.0)

    Config_feed_xmlUrl=mua://#mh/mail/(.+)
    Config_feed_title=New e-mails (Sylpheed)
    Config_feed_htmlUrl=
    Config_feed_cacheId=mua_#mh_mail
    Config_feed_singleEntry=1
    Config_feed_needleRegEx=^\s*([0-9]+).+
    Config_feed_replacement=$1
    Config_feed_needleRegEx=^[0-9\s]+(.*)
    Config_feed_replacement=$1
