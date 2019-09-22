<template>
<body data-page="Ershou_Web_Property_List_SearchPage">
  <div id="container">
    <div id="content">
      <div class="div-border items-list">
        <!-- 从区域开始区域 begin-->

        <!-- 区域 begin-->
        <div class="items">
          <span class="item-title">区域：</span>
          <span class="elems-l">
            <button type="button" value="全部" class="selected-item">全部</button>
            <button type="button" value="龙岗">龙岗</button>
            <button type="button" value="南山">南山</button>
            <button type="button" value="宝安">宝安</button>
            <button type="button" value="福田">福田</button>
            <button type="button" value="罗湖">罗湖</button>
            <button type="button" value="盐田">盐田</button>
          </span>
        </div>
        <!-- 区域 end-->

        <!-- 售价 begin-->
        <div class="items">
          <span class="item-title">售价：</span>
          <span class="elems-l">
            <button type="button" value="全部" class="selected-item">全部</button>
            <button type="button" value="50万以下">50万以下</button>
            <button type="button" value="50-100万">50-100万</button>
            <button type="button" value="100-150万">100-150万</button>
            <button type="button" value="150-200万">150-200万</button>
            <button type="button" value="200-250万">200-250万</button>
            <button type="button" value="250-300万">250-300万</button>
            <button type="button" value="300-350万">300-350万</button>
            <button type="button" value="350-400万">350-400万</button>
            <button type="button" value="400-500万">400-500万</button>
            <button type="button" value="500-700万">500-700万</button>
            <button type="button" value="700-1000万">700-1000万</button>
            <button type="button" value="1000-1500万">1000-1500万</button>
            <button type="button" value="1500万以上">1500万以上</button>
            <div class="pricecond">
              <form
                id="pr_form_apf_id_11"
                onsubmit="return priceCondition.submit(0)"
                action="https://shenzhen.anjuke.com/sale/"
              >
                <input
                  name="from_price"
                  class="from-price"
                  id="from_price"
                  type="text"
                  maxlength="5"
                  value
                  autocomplete="off"
                />
                -
                <input
                  name="to_price"
                  class="to-price"
                  id="to_price"
                  type="text"
                  maxlength="5"
                  value
                  autocomplete="off"
                />&nbsp;
                <span>万</span>

                <input
                  class="smit"
                  id="pricerange_search"
                  style="display:none"
                  type="submit"
                  value="确定"
                />
              </form>
            </div>
          </span>
        </div>

        <!-- 面积 begin-->
        <div class="items">
          <span class="item-title">面积：</span>
          <span class="elems-l">
            <button type="button" value="全部" class="selected-item">全部</button>
            <button type="button" value="50m²以下">50m²以下</button>
            <button type="button" value="50-70m²">50-70m²</button>
            <button type="button" value="70-90m²">70-90m²</button>
            <button type="button" value="90-110m²">90-110m²</button>
            <button type="button" value="110-130m²">110-130m²</button>
            <button type="button" value="130-150m²">130-150m²</button>
            <button type="button" value="150-200m²">150-200m²</button>
            <button type="button" value="200-300m²">200-300m²</button>
            <button type="button" value="300m²以上">300m²以上</button>
            <div class="areacond" style="display: inline">
              <form
                id="pr_form_apf_id_11"
                onsubmit="return areaCondition.submit(0)"
                action="https://shenzhen.anjuke.com/sale/"
                method="get"
              >
                <input
                  name="from_area"
                  class="from-area"
                  id="from_area"
                  type="text"
                  maxlength="5"
                  value
                  autocomplete="off"
                />
                -
                <input
                  name="to_area"
                  class="to-area"
                  id="to_area"
                  type="text"
                  maxlength="5"
                  value
                  autocomplete="off"
                />&nbsp;
                <span>m²</span>

                <input
                  class="smit"
                  id="arearange_search"
                  style="display:none"
                  type="submit"
                  value="确定"
                />
              </form>
            </div>
          </span>
        </div>

        <!--   用途 begin-->
        <div class="items">
          <span class="item-title">类型：</span>
          <span class="elems-l">
            <button type="button" value="全部" class="selected-item">全部</button>
            <button type="button" value="住宅">住宅</button>
            <button type="button" value="公寓">公寓</button>
            <button type="button" value="别墅">别墅</button>
            <button type="button" value="研发用地<">研发用地</button>
            <button type="button" value="仓储">仓储</button>
            <button type="button" value="写字楼">写字楼</button>
            <button type="button" value="宿舍">宿舍</button>
            <button type="button" value="厂房">厂房</button>
            <button type="button" value="商业">商业</button>
            <button type="button" value="文化活动用房">文化活动用房</button>
            <button type="button" value="酒店">酒店</button>
            <button type="button" value="食堂">食堂</button>
            <button type="button" value="综合楼">综合楼</button>
            <button type="button" value="其他">其他</button>
          </span>
        </div>

        <!-- 其他 begin-->
        <div id="condmenu">
          <div class="search_bottom clearfix">
            <ul class="condul clearfix">
              <li class="condlist_tip">
                <span>更多：</span>
              </li>
              <!-- house age start -->
              <li id="condhouseage_id">
                <a href="javascript:void(0);">
                  <span class="select_item">
                    <span class="txt" id="condhouseage_txt_id">项目名称</span>
                    <span class="icon">&nbsp;</span>
                  </span>
                  <!--[if IE 7]><!-->
                </a>
                <!--<![endif]-->
                <!--[if IE 8]><!-->


                <!--<![endif]-->
                <!--[if !IE]>-->


                <!--<![endif]-->
                <!--[if lte IE 6]>
                <iframe src="" style="position:absolute;visibility:inherit; top:0px; left:-1px; width:99px; height:105px;z-index:-1;opacity:.0;filter:alpha(opacity=0); -moz-opacity:0;"></iframe>
                <table><tr><td>
                <![endif]-->


                <ul>
                  <li class="selected">
                    <a href="https://shenzhen.anjuke.com/sale/" rel="nofollow">全部</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/y2/" rel="nofollow">2010年以后</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/y3/" rel="nofollow">2005年以后</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/y5/" rel="nofollow">2000年以后</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/y6/" rel="nofollow">2000年以前</a>
                  </li>
                </ul>
                <!--[if lte IE 6]></td></tr></table></a><![endif]-->
              </li>
              <!-- house age end -->

              <!-- house type start -->
              <li id="condusetype_id">
                <a href="javascript:void(0);">
                  <span class="select_item">
                    <span class="txt" id="condusetype_txt_id">房源编码</span>
                    <span class="icon">&nbsp;</span>
                  </span>
                  <!--[if IE 7]><!-->
                </a>
                <!--<![endif]-->
                <!--[if IE 8]><!-->


                <!--<![endif]-->
                <!--[if !IE]>-->


                <!--<![endif]-->
                <!--[if lte IE 6]>
                <iframe src="" style="position:absolute;visibility:inherit; top:0px; left:-1px; width:99px; height:105px;z-index:-1;opacity:.0;filter:alpha(opacity=0); -moz-opacity:0;"></iframe>
                <table><tr><td>
                <![endif]-->


                <ul>
                  <li class="selected">
                    <a href="https://shenzhen.anjuke.com/sale/" rel="nofollow">全部</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/t13/" rel="nofollow">公寓</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/t14/" rel="nofollow">普通住宅</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/t15/" rel="nofollow">别墅</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/t12/" rel="nofollow">平房</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/t16/" rel="nofollow">其它</a>
                  </li>
                </ul>
                <!--[if lte IE 6]></td></tr></table></a><![endif]-->
              </li>
              <!-- house type end -->
              <!-- house floor start -->
              <li id="condfloor_id">
                <a href="javascript:void(0);">
                  <span class="select_item">
                    <span class="txt" id="condfloornum_txt_id">发布日期</span>
                    <span class="icon">&nbsp;</span>
                  </span>
                  <!--[if IE 7]><!-->
                </a>
                <!--<![endif]-->
                <!--[if IE 8]><!-->


                <!--<![endif]-->
                <!--[if !IE]>-->


                <!--<![endif]-->
                <!--[if lte IE 6]>
                <iframe src="" style="position:absolute;visibility:inherit; top:0px; left:-1px; width:99px; height:105px;z-index:-1;opacity:.0;filter:alpha(opacity=0); -moz-opacity:0;"></iframe>
                <table><tr><td>
                <![endif]-->


                <ul>
                  <li class="selected">
                    <a href="https://shenzhen.anjuke.com/sale/" rel="nofollow">全部</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/f6/" rel="nofollow">一个月内</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/f12/" rel="nofollow">三个月内</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/f13/" rel="nofollow">半年内</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/f13/" rel="nofollow">一年内</a>
                  </li>
                </ul>
                <!--[if lte IE 6]></td></tr></table></a><![endif]-->
              </li>
              <!-- house floor end -->
              <!-- 朝向 -->
              <li id="condarrow_id">
                <a href="javascript:void(0);">
                  <span class="select_item">
                    <span class="txt" id="condhousearrow_txt_id">状态</span>
                    <span class="icon">&nbsp;</span>
                  </span>
                  <!--[if IE 7]><!-->
                </a>
                <!--<![endif]-->
                <!--[if IE 8]><!-->


                <!--<![endif]-->
                <!--[if !IE]>-->


                <!--<![endif]-->
                <!--[if lte IE 6]>
                <iframe src="" style="position:absolute;visibility:inherit; top:0px; left:-1px; width:99px; height:105px;z-index:-1;opacity:.0;filter:alpha(opacity=0); -moz-opacity:0;"></iframe>
                <table><tr><td>
                <![endif]-->


                <ul>
                  <li class="selected">
                    <a href="https://shenzhen.anjuke.com/sale/" rel="nofollow">在售</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/l1/" rel="nofollow">已售</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/l2/" rel="nofollow">全部</a>
                  </li>
                </ul>
                <!--[if lte IE 6]></td></tr></table></a><![endif]-->
              </li>
              <!-- 朝向 end -->

              <!-- 装修 -->
              <li id="conddecoration_id">
                <a href="javascript:void(0);">
                  <span class="select_item">
                    <span class="txt" id="conddecoration_txt_id">排序</span>
                    <span class="icon">&nbsp;</span>
                  </span>
                  <!--[if IE 7]><!-->
                </a>
                <!--<![endif]-->
                <!--[if IE 8]><!-->


                <!--<![endif]-->
                <!--[if !IE]>-->


                <!--<![endif]-->
                <!--[if lte IE 6]>
                <iframe src="" style="position:absolute;visibility:inherit; top:0px; left:-1px; width:99px; height:105px;z-index:-1;opacity:.0;filter:alpha(opacity=0); -moz-opacity:0;"></iframe>
                <table><tr><td>
                <![endif]-->


                <ul>
                  <li class="selected">
                    <a href="https://shenzhen.anjuke.com/sale/" rel="nofollow">按价格从高到底</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/d10/" rel="nofollow">按价格从低到高</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/d11_123/" rel="nofollow">按发布日期从近到远</a>
                  </li>
                  <li>
                    <a href="https://shenzhen.anjuke.com/sale/d13/" rel="nofollow">按发布日期从远到近</a>
                  </li>
                </ul>
                <!--[if lte IE 6]></td></tr></table></a><![endif]-->
              </li>
              <!-- 装修 end -->
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</template>

<script>
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.div-border {
  border: 1px solid #d8d8d8;
  border-radius: 5px;
}
.items-list {
  padding: 5px 10px;
  border-radius: 0;
  position: relative;
  z-index: 1;
}
#header,
#content {
  width: 100%;
}
body,
h1,
h2,
h3,
h4,
h5,
h6,
dl,
dt,
dd,
ul,
ol,
li,
pre,
code,
form,
fieldset,
button,
input,
textarea,
p,
address,
em,
label,
img,
th,
td,
iframe,
sub,
sup {
  padding: 0;
  margin: 0;
}
h1,
h2,
h3,
h4,
h5,
h6,
p,
dl,
dt,
dd,
ol,
ul,
li {
  margin: 0;
  padding: 0;
}
ol,
ul {
  list-style: none;
}
.clearfix,
#content {
  *zoom: 1;
}
#content {
  margin: 0 auto;
}
#content {
  font-family: "Microsoft YaHei", "微软雅黑", Tahoma, Arial, simhei, Helvetica,
    sans-serif;
  font-size: 13px;
  width: 1180px;
  position: relative;
}
#container {
  width: 970px;
  margin: 0 auto;
}
#container {
  width: 100% !important;
  _width: 1180px;
  _margin: 0 auto;
  _display: block;
}
body {
  color: #333;
  font-family: "Microsoft YaHei", "宋体", Arial, "宋体", Helvetica, sans-serif;
  font-size: 12px;
}
.items {
  line-height: 26px;
  padding: 4px 10px;
  border-bottom: 1px dashed #d8d8d8;
}
#condmenu,
.search_bottom .more-link58 {
  _display: inline;
}
.search_bottom {
  padding-left: 0px;
  position: relative;
  height: 45px;
  padding-top: 0px;
  margin-right: 0px;
  clear: both;
}
#condmenu .condul {
  padding: 0;
  list-style-type: none;
}
#condmenu .condul {
  line-height: 20px;
  padding-top: 14px;
  height: 31px;
}
.condul li {
  margin-left: 10px;
}
.filtersingle-new #filter_is_metro_new,
#filter_is_school_new,
#filter_is_trueH_new,
#filter_is_video_new,
.filter_check {
  position: relative;
  margin-left: 0px;
  *margin-left: 25px;
  line-height: 22px;
}
#filter_is_metro,
#filter_is_school,
#filter_is_elevator,
#filter_is_video,
#filter_is_trueH,
#filter_is_confirm,
#filter_is_yzgp,
.filter_check {
  margin-left: 15px;
  *margin-left: 25px;
  line-height: 26px;
  position: relative;
}
#filter_is_school {
  margin-left: 15px;
}
#condmenu li {
  float: left;
  display: inline;
}
#condmenu .condlist_tip {
  float: left;
  color: #999;
  margin-right: 0px;
}
#condmenu #selectfitment_id,
#condmenu #selectschool_id,
#condmenu #condbrand_id,
#condmenu #condhouseage_id,
#condmenu #condfloor_id,
#condmenu #condarrow_id,
#condmenu #conddecoration_id,
#condmenu #condusetype_id,
#condmenu #condeconomics_id,
#condmenu #condpubtime_id {
  position: relative;
}
a:link,
a:visited,
a:active {
  color: #0041d9;
  text-decoration: none;
  outline: none;
}
.search_bottom a {
  display: -moz-inline-stack;
  display: inline-block;
  zoom: 1;
}
#condmenu a {
  height: 100%;
  width: 80px;
  text-decoration: none;
  background: #ffffff;
  border: 1px solid #b3b3b3;
  margin-left: 10px;
  margin-right: 8px;
  padding: 2px 0;
  color: #333333;
}
#condmenu ul ul a {
  display: block;
  background: #ffffff;
  color: #333333;
  height: 100%;
  line-height: 12px;
  padding: 6px 12px;
  border: none;
  width: 56px;
}
#condmenu .condul a {
  margin-left: 0px;
}
#condmenu .selected a {
  color: #f60 !important;
}
#condmenu .condul a {
  width: 91px;
  _width: 100px;
  height: 20px;
  line-height: 20px;
  padding: 0;
  border: 1px solid #d1d1d1;
  margin-right: 0px;
}
#condmenu ul ul li.selected a {
  color: #333;
}
#condmenu .condul ul a,
#condmenu .condul ul a:link,
#condmenu .condul ul a:visited {
  display: block;
  width: 72px;
  height: 100%;
  padding: 6px 8px;
  margin: 0;
  line-height: 12px;
  color: #333;
  background: #fff;
  border: 0 none;
}
#condmenu .condul #condeconomics_id a {
  width: 112px;
  _width: 112px;
}
#condmenu ul ul {
  visibility: hidden;
  position: absolute;
  height: 0px;
  top: 22px;
  _top: 21px;
  left: 0px;
  width: 96px;
  z-index: 1000;
  border: 1px solid #ccc;
  border-top: none;
}
#condmenu .condul ul {
  overflow: hidden;
  zoom: 1;
  background: #fff;
  padding: 4px 0px;
}
#condmenu .condul #condusetype_id a,
#condmenu .condul #condeconomics_id a,
#condmenu .condul #condusetype_id ul {
  display: block;
}
#condmenu .condul #condeconomics_id ul {
  width: 112px;
  _width: 112px;
}
#condmenu ul ul li {
  display: block;
  height: auto;
  line-height: 12px;
  width: 70px;
  _overflow: hidden;
  _zoom: 1;
  margin-left: 0px;
}
#condmenu .select_item span.txt {
  display: inline-block;
  padding-left: 7px;
  white-space: nowrap;
  width: 60px;
  cursor: pointer;
}
#condmenu .condul a .icon {
  position: absolute;
  right: 7px;
  top: 9px;
  display: block;
  overflow: hidden;
  width: 0px;
  height: 0px;
  line-height: 0;
  border: 4px solid;
  border-color: #7b7b7b #fff #fff #fff;
}
#condmenu .condul #condfloor_id ul,
#condmenu .condul #condarrow_id ul,
#condmenu .condul #conddecoration_id ul {
  width: 91px;
  _width: 100px;
}
#condmenu .condul #condusetype_id ul {
  width: 91px;
  _width: 100px;
}
#condmenu #condhouseage_id a {
  display: inline-block;
  margin-left: 0px;
}
#condmenu #condhouseage_id ul {
  width: 91px;
  _width: 100px;
}
#condmenu #condhouseage_id ul li {
  width: 100px;
  margin-left: 0px;
}
#condmenu #condhouseage_id ul a {
  width: 76px;
}
#condmenu #condhouseage_id ul a:link,
#condmenu #condhouseage_id ul a:visited,
#condmenu #condhouseage_id ul a:hover,
#condmenu #condhouseage_id ul a:active {
  width: 84px;
}
#condmenu #condhouseage_id .select_item span.txt {
  width: 70px;
}
input,
select,
input,
textarea {
  font-size: 12px;
  outline: none;
}
select,
input {
  vertical-align: middle;
}
.filter_check input {
  margin-right: 5px;
}
.filter_check input {
  vertical-align: middle;
}
.filter_check label {
  vertical-align: middle;
}
address,
caption,
th,
cite,
code,
em {
  font-style: normal;
  font-weight: normal;
}
.iconfont {
  color: #000;
  text-align: center;
  font-style: normal;
  display: inline-block;
  vertical-align: middle;
  font-family: "iconfont";
}
.filter_check .tips-icon-truesingleold {
  display: inline-block;
  vertical-align: middle;
  padding: 0 3px;
  cursor: pointer;
  z-index: 2;
  color: #999;
}
.filter_check .tips-box-truesingleold {
  display: none;
  position: absolute;
  left: 44px;
  bottom: 33px;
  width: 220px;
  height: 54px;
  padding-top: 8px;
  border: 1px solid #e6e6e6;
  background: #fff;
}
.filter_check .tips-box-truesingleold p {
  padding-left: 15px;
  line-height: 24px;
  height: 24px;
}
.filter_check .tips-box-truesingleold .arrow-wrap {
  width: 0px;
  height: 0px;
  border: 8px solid transparent;
  border-top-color: #e6e6e6;
  position: absolute;
  bottom: -17px;
  left: 31px;
}
.filter_check .tips-box-truesingleold .arrow {
  width: 0px;
  height: 0px;
  border: 8px solid transparent;
  border-top-color: white;
  position: absolute;
  top: -9px;
  left: -8px;
}
#filter_is_personal input,
#filter_is_metro input,
#filter_is_school input {
  border-radius: 5px;
  margin-right: 3px;
  *margin-right: 0;
}
#filter_is_metro label,
#filter_is_school label {
  _vertical-align: bottom;
}
.items .item-title {
  display: inline-block;
  *display: inline;
  *zoom: 1;
  color: #999;
  margin-right: 15px;
  vertical-align: top;
}
.items .elems-l {
  width: 1082px;
  _width: 1078px;
  display: inline-block;
  *display: inline;
  *zoom: 1;
}
.items span .selected-item,
.items .sub-items .selected-item {
  color: #ff6600;
  font-weight: bold;
  margin-right: 20px;
}
.items button {
  margin-right: 20px;
  display: inline-block;
  *display: inline;
  *zoom: 1;
  border-style: none;
  cursor: pointer;
}
.items a:link,
.items a:visited {
  color: #333333;
}
.items .pricecond,
.items .areacond {
  height: 26px;
  line-height: 26px;
  display: inline-block;
  *display: inline;
  *zoom: 1;
  vertical-align: bottom;
  *margin-top: 2px;
}
.items form {
  display: inline-block;
  *display: inline;
  *zoom: 1;
  vertical-align: top;
}
.items form input {
  border: 1px solid #cccccc;
  border-radius: 3px;
  height: 16px;
  line-height: 16px;
  padding: 0 3px;
  text-align: center;
  margin: -4px 0px 0px 0px;
  *margin-top: 0px;
  width: 22px;
}
.items form input.smit {
  width: 40px;
  height: 22px;
  margin-left: 3px;
  color: #333333;
  cursor: pointer;
  border: 1px solid #cccccc;
  background-color: #f6f6f6;
}
</style>
