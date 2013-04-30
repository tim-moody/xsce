function squid()
{
	case "$1" in
	"yes")
        touch $SETUPSTATEDIR/squid
        # create the cache directories
        mkdir -p /library/cache
        chown squid:squid /library/cache
        squid -z
        ## Update flag for httpd cache
        if [ ! -e /etc/sysconfig/xs_httpcache_on ]; then
            touch /etc/sysconfig/xs_httpcache_on
            etckeeper-if-selected 'xs-setup force-create httpcache flag'
        fi
        /etc/sysconfig/iptables-config
        systemctl condrestart iptables.service
        systemctl enable squid.service 2>&1 | tee -a $LOG
        set +e; systemctl condrestart squid.service 2>&1 | tee -a $LOG; set -e
        ;;
    "no")
        systemctl disable squid.service 2>&1 | tee -a $LOG
        systemctl stop squid.service 2>&1 | tee -a $LOG
        rm /etc/sysconfig/xs_httpcache_on
        rm $SETUPSTATEDIR/squid
        /etc/sysconfig/iptables-config
        # reinitialize the iptables to just use masqueradeing
        systemctl condrestart iptables.service
        ;;
    esac
}