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

##### User: joten (2014-03-18, owl-u 0.3.0)

    Config_feed_xmlUrl=http://feeds.feedburner.com/Liliputing
    Config_feed_title=Liliputing
    Config_feed_htmlUrl=http://liliputing.com
    Config_feed_cacheId=feeds_feedburner_com_Liliputing
    Config_feed_htmlSource=body
    Config_feed_needleRegEx=.*<main c
    Config_feed_replacement=<main c
    Config_feed_needleRegEx=<div class="crafty-social-buttons crafty-social-share-buttons">.*
    Config_feed_needleRegEx=<iframe.+?</iframe>
    Config_feed_needleRegEx=<script.+?</script>
    Config_feed_needleRegEx=<style.+?</style>

    Config_feed_xmlUrl=http://feeds.feedburner.com/netbooknewsde
    Config_feed_title=Mobilegeeks.de
    Config_feed_htmlUrl=http://www.mobilegeeks.de
    Config_feed_cacheId=feeds_feedburner_com_netbooknewsde
    Config_feed_htmlSource=body
    Config_feed_needleRegEx=.*<div id="main">
    Config_feed_needleRegEx=<!-- google_ad_section_end -->.*
    Config_feed_needleRegEx=<iframe.+?</iframe>
    Config_feed_needleRegEx=<script.+?</script>
    Config_feed_needleRegEx=<style.+?</style>

    Config_feed_xmlUrl=http://www.osnews.com/files/recent.xml
    Config_feed_title=OSNews
    Config_feed_htmlUrl=http://www.osnews.com
    Config_feed_cacheId=www_osnews_com_files_recent_xml
    Config_feed_htmlSource=text
    Config_feed_needleRegEx=.*<div id="content">(.+)<div class="newsfooter1">.*
    Config_feed_replacement=$1

    Config_feed_xmlUrl=http://www.pro-linux.de/backend/pro-linux.rdf
    Config_feed_title=Pro-Linux News
    Config_feed_htmlUrl=http://www.pro-linux.de
    Config_feed_cacheId=www_pro-linux_de_rdf
    Config_feed_htmlSource=text
    Config_feed_needleRegEx=.*<div id="news">(.+)<div id="item_npinfo">.*
    Config_feed_replacement=$1

    Config_feed_xmlUrl=http://www.autohotkey.com/board/topic/58661-owl-u-feed-reader
    Config_feed_title=owl-u@autohotkey.com/forum
    Config_feed_htmlUrl=http://www.autohotkey.com/board/topic/58661-owl-u-feed-reader
    Config_feed_cacheId=autohotkey_com_board_topic_58661
    Config_feed_htmlSource=text
    Config_feed_singleEntry=1
    Config_feed_needleRegEx=.*<span class='ipsType_small'>
    Config_feed_needleRegEx=</span>.*
