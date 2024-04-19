 passwall-smartdns分支编译 [xiaorouji](https://github.com/xiaorouji/openwrt-passwall/tree/luci-smartdns-dev)

依赖同passwall [xiaorouji/openwrt-passwall/releases](https://github.com/xiaorouji/openwrt-passwall/releases)

需要安装[smartdns](https://github.com/pymumu/smartdns/releases)后才会有dns分流选项:

![imag dns分流选项](https://github.com/yoier/passwall-smartdns-dev-build/blob/luci-smartdns-new-version/img/1.png)




END:

由于smartdns无法做到dns精准分流，dns由默认节点解析返回，实际访问时会使用自己设置的节点，导致dns解析和访问网站时不是同一节点。

对于单个节点用户，多节点都在同一地区，多节点不同地区但不需要分流的的用户影响不大。

目前已改用passwall2，直接在xray中分流dns，结果更精准，也不用安装其他插件。
