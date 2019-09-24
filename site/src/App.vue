<template>
  <el-container>
    <el-header>
      <div>深圳市二手房房源</div>
    </el-header>
    <el-main>
      <el-row class="formContainer">
        <el-form :model="form" label-position="left" label-width="100px" size="mini">
          <el-form-item label="区域">
            <el-col :span="18">
              <el-radio-group v-model="form.qushu">
                <el-radio-button label>全部</el-radio-button>
                <el-radio-button label="南山">南山</el-radio-button>
                <el-radio-button label="福田">福田</el-radio-button>
                <el-radio-button label="罗湖">罗湖</el-radio-button>
                <el-radio-button label="宝安">宝安</el-radio-button>
                <el-radio-button label="盐田">盐田</el-radio-button>
                <el-radio-button label="龙岗">龙岗</el-radio-button>
              </el-radio-group>
            </el-col>
          </el-form-item>
          <el-form-item label="价格（万）">
            <el-radio-group v-model="form.jiage">
              <el-radio-button label>全部</el-radio-button>
              <el-radio-button label="0-200">200万以下</el-radio-button>
              <el-radio-button label="200-400">200-400万</el-radio-button>
              <el-radio-button label="400-500">400-500万</el-radio-button>
              <el-radio-button label="500-600">500-600万</el-radio-button>
              <el-radio-button label="600-1000">600-1000万</el-radio-button>
              <el-radio-button label="1000-">1000万以上</el-radio-button>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="面积（m²）">
            <el-radio-group v-model="form.mianji">
              <el-radio-button label>全部</el-radio-button>
              <el-radio-button label="0-70">70m²以下</el-radio-button>
              <el-radio-button label="70-90">70-90m²</el-radio-button>
              <el-radio-button label="90-110">90-110m²</el-radio-button>
              <el-radio-button label="110-130">110-130m²</el-radio-button>
              <el-radio-button label="130-160">130-160m²</el-radio-button>
              <el-radio-button label="160-">160m²以上</el-radio-button>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="类型">
            <el-radio-group v-model="form.leixing">
              <el-radio-button label>全部</el-radio-button>
              <el-radio-button label="住宅">住宅</el-radio-button>
              <el-radio-button label="公寓">公寓</el-radio-button>
              <el-radio-button label="别墅">别墅</el-radio-button>
              <el-radio-button label="研发用地">研发用地</el-radio-button>
              <el-radio-button label="仓储">仓储</el-radio-button>
              <el-radio-button label="写字楼">写字楼</el-radio-button>
              <el-radio-button label="宿舍">宿舍</el-radio-button>
              <el-radio-button label="厂房">厂房</el-radio-button>
              <el-radio-button label="商业">商业</el-radio-button>
              <el-radio-button label="文化活动用房">文化活动用房</el-radio-button>
              <el-radio-button label="酒店">酒店</el-radio-button>
              <el-radio-button label="食堂">食堂</el-radio-button>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="更多">
            <el-col :span="3">
              <el-input v-model="form.xiangmumingchen" placeholder="项目名称"></el-input>
            </el-col>
            <el-col :span="3">
              <el-input v-model="form.fangyuanbianma" placeholder="房源编码"></el-input>
            </el-col>
            <el-col :span="3">
              <el-select v-model="form.faburiqi" clearable placeholder="发布日期（全部）">
                <el-option label="一个月内" value="30"></el-option>
                <el-option label="三个月内" value="90"></el-option>
                <el-option label="半年内" value="180"></el-option>
              </el-select>
            </el-col>
            <el-col :span="3">
              <el-select v-model="form.zhuangtai" clearable placeholder="状态（全部）">
                <el-option label="在售" value="在售"></el-option>
                <el-option label="已售" value="已售"></el-option>
              </el-select>
            </el-col>
            <el-col :span="6">
              <el-select v-model="form.orderby" clearable placeholder="排序（发布日期由近到远）">
                <el-option label="按价格从高到低" value="jiagewan desc"></el-option>
                <el-option label="按价格从低到高" value="jiagewan"></el-option>
                <el-option label="按发布日期由近到远" value="faburiqi desc"></el-option>
                <el-option label="按发布日期由远到近" value="faburiqi"></el-option>
              </el-select>
            </el-col>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSubmit" v-loading.fullscreen.lock="loading">查询</el-button>
          </el-form-item>
        </el-form>
      </el-row>
      <el-row class="tableContainer">
        <el-table :data="tableData">
          <el-table-column prop="xiangmumingchen" label="项目名称"></el-table-column>
          <el-table-column prop="hetongliushuihao" label="合同流水号"></el-table-column>
          <el-table-column prop="qushu" label="区属"></el-table-column>
          <el-table-column prop="mianjipingfangmi" label="面积(㎡)"></el-table-column>
          <el-table-column prop="yongtu" label="用途"></el-table-column>
          <el-table-column prop="louceng" label="楼层"></el-table-column>
          <el-table-column prop="fangyuanbianma" label="房源编码"></el-table-column>
          <el-table-column prop="jiagewan" label="价格（万）"></el-table-column>
          <el-table-column prop="dailizhongjie" label="代理中介"></el-table-column>
          <el-table-column prop="faburiqi" label="发布日期"></el-table-column>
          <el-table-column prop="lianxidianhua" label="联系电话"></el-table-column>
          <el-table-column prop="zhuangtai" label="状态"></el-table-column>
          <el-table-column prop="shouchuriqi" label="售出日期"></el-table-column>
        </el-table>
      </el-row>
      <el-row class="paginationContainer">
        <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="form.currentPage"
          :page-sizes="pageSizes"
          :page-size="form.pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
        ></el-pagination>
      </el-row>
    </el-main>
  </el-container>
</template>

<script>
const axios = require("axios");

export default {
  data: function() {
    return {
      form: {
        xiangmumingchen: "",
        qushu: "",
        leixing: "",
        jiage: "",
        mianji: "",
        fangyuanbianma: "",
        faburiqi: "",
        zhuangtai: "",
        orderby: "",
        currentPage: 1,
        pageSize: 20
      },
      loading: false,
      tableData: [],
      pageSizes: [20, 50, 100, 200],
      total: 0,
      dataUrl: "http://94.191.116.177:15687"
    };
  },
  methods: {
    onSubmit() {
      this.pullData();
    },
    handleSizeChange(val) {
      this.form.pageSize = val;
      this.pullData();
    },
    handleCurrentChange(val) {
      this.form.currentPage = val;
      this.pullData();
    },
    pullData() {
      this.loading = true;
      axios
        .get(this.dataUrl, { params: this.form })
        .then(res => {
          this.tableData = res.data.tableData;
          this.total = res.data.total;
          this.loading = false;
        })
        .catch(err => {
          console.error(err);
        });
    }
  },
  mounted: function() {
    this.pullData();
  }
};
</script>

<style scoped>
.el-container {
  margin-left: 10%;
  margin-right: 10%;
}
.el-header div {
  margin-top: 20px;
  margin-left: 20%;
  margin-right: 20%;
  text-align: center;
}

.line-through {
  text-align: center;
}
</style>
