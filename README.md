 passwall-smartdns分支编译 [xiaorouji](https://github.com/xiaorouji/openwrt-passwall/tree/luci-smartdns-dev)

依赖同passwall [xiaorouji/openwrt-passwall/releases](https://github.com/xiaorouji/openwrt-passwall/releases)

需要安装[smartdns](https://github.com/pymumu/smartdns/releases)(~~compat版是为了向下兼容,23.05及以上安装后可能导致luci不显示smartdns服务~~)后才会有dns分流选项:

![imag dns分流选项](https://github.com/yoier/passwall-smartdns-dev-build/blob/luci-smartdns-new-version/img/1.png)<br>
可直接绑定smartdns到53端口。
<br>
<br>
<br>
# END:

由于smartdns无法做到dns精准分流，dns由默认节点解析返回，实际访问时会使用自己设置的节点，导致dns解析和访问网站时不是同一节点。

对于单个节点用户，多节点都在同一地区，多节点不同地区但不需要分流的的用户影响不大。

本人已改用passwall2，直接在xray中分流dns，结果更精准，开启fakedns降低延时，也不用安装其他插件。

目前本人使用主路由+旁路网关，旁路网关设备安装passwall2，dnsmasq设置中关闭缓存(修改缓存值为0)，lan口自定义dns指向主路由;主路由安装smartdns并绑定53端口作为主dns。实现国内网站由smartdns解析，国外由xray分流解析。

## 需要注意的是: 

如果你在主路由dhcp选项设置了旁路网关和及其dns，当设置smartdns为主dns时，smartdns会在dhcp选项中添加值通告dns指向主路由，当dhcp租约到期后，再次分配的dns会指向主路由，导致passwall2分流失效。

## 解决方法:<br>
在主路由上注释掉/etc/init.d/smartdns中的97和123行:<br># uci -q add_list dhcp.lan.dhcp_option="6,$hostip"<br># uci -q del_list dhcp.lan.dhcp_option="6,$hostip"
