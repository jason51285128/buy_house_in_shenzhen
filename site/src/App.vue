<template>
  <el-container>
    <el-header>深圳市二手房房源</el-header>
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
            <el-col :span="14">
              <el-radio-group v-model="form.jiagel" style="width:100%">
                <el-radio-button label>全部</el-radio-button>
                <el-radio-button label="0-100">100万以下</el-radio-button>
                <el-radio-button label="100-200">100-200万</el-radio-button>
                <el-radio-button label="200-300">200-300万</el-radio-button>
                <el-radio-button label="300-400">300-400万</el-radio-button>
                <el-radio-button label="400-500">400-500万</el-radio-button>
                <el-radio-button label="500-600">500-600万</el-radio-button>
                <el-radio-button label="600-1000">600-1000万</el-radio-button>
                <el-radio-button label="1000-">1000万以上</el-radio-button>
              </el-radio-group>
            </el-col>
            <el-col :span="4">
              <el-col :span="8">
                <el-input v-model="form.jiagel" placeholder="最低"></el-input>
              </el-col>
              <el-col :span="8">-</el-col>
              <el-col :span="8">
                <el-input v-model="form.jiageh" placeholder="最高"></el-input>
              </el-col>
            </el-col>
          </el-form-item>
        </el-form>
      </el-row>
      <el-row class="tableContainer"></el-row>
      <el-row class="paginationContainer"></el-row>
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
        jiagel: "",
        jiageh: "",
        mianjil: "",
        mianjih: "",
        fangyuanbianma: "",
        faburiqi: "",
        zhuangtai: "",
        orderby: ""
      },
      loading: false,
      originData: [],
      tableData: [],
      currentPage: 1,
      pageSize: 20,
      pageSizes: [20, 50, 100, 200],
      total: 0,
      dataUrl: "http://94.191.116.177:15687"
    };
  },
  methods: {
    onSubmit() {
      this.loading = true;
      axios
        .get(this.dataUrl, { params: this.form })
        .then(res => {
          this.originData = res.data.tableData;
          this.total = this.originData.length;
          this.currentPage = 1;
          this.tableData = this.originData.slice(
            0,
            this.currentPage * this.pageSize
          );
          this.loading = false;
        })
        .catch(err => {
          console.error(err);
        });
    },
    handleSizeChange(val) {
      this.currentPage = 1;
      this.pageSize = val;
      this.tableData = this.originData.slice(
        0,
        this.currentPage * this.pageSize
      );
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.tableData = this.originData.slice(
        (this.currentPage - 1) * this.pageSize,
        this.currentPage * this.pageSize
      );
    }
  }
};
</script>

<style scoped>
.el-container {
  margin-left: 10%;
  margin-right: 10%;
}
</style>




<tmp>
<el-form :model="form" label-position="left" label-width="100px" size="mini">

          
        <el-form-item label="面积（m²）">
          <el-col :span="18">
            <el-radio-group v-model="form.mianjil">
              <el-radio-button label>全部</el-radio-button>
              <el-radio-button label="0-60">60m²以下</el-radio-button>
              <el-radio-button label="60-90">60-90m²</el-radio-button>
              <el-radio-button label="90-110">90-110m²</el-radio-button>
              <el-radio-button label="110-130">110-130m²</el-radio-button>
              <el-radio-button label="130-160">130-160m²</el-radio-button>
              <el-radio-button label="160-">160m²以上</el-radio-button>
            </el-radio-group>
          </el-col>
          <el-col :span="1">
            <el-input v-model="form.mianjil" placeholder="最小"></el-input>
          </el-col>
          <el-col :span="1">-</el-col>
          <el-col :span="1">
            <el-input v-model="form.mianjih" placeholder="最大"></el-input>
          </el-col>
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
            <el-select v-model="form.faburiqi" placeholder="发布日期">
              <el-option label="一个月内" value="30"></el-option>
              <el-option label="三个月内" value="90"></el-option>
              <el-option label="半年内" value="180"></el-option>
            </el-select>
          </el-col>
          <el-col :span="3">
            <el-select v-model="form.zhuangtai" placeholder="状态">
              <el-option label="在售" value="在售"></el-option>
              <el-option label="已售" value="已售"></el-option>
            </el-select>
          </el-col>
          <el-col :span="3">
            <el-select v-model="form.orderby" placeholder="排序">
              <el-option label="按价格从高到低" value="jiagewan desc"></el-option>
              <el-option label="按价格从低到高" value="jiagewan"></el-option>
              <el-option label="按发布日期由近到远" value="faburiqi desc"></el-option>
              <el-option label="按发布日期由远到近" value="faburiqi"></el-option>
            </el-select>
          </el-col>
        </el-form-item>
        <el-form-item>
          <el-col :span="2">
            <el-button type="primary" @click="onSubmit" v-loading.fullscreen.lock="loading">查询</el-button>
          </el-col>
        </el-form-item>
      </el-form>
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
      <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="currentPage"
        :page-sizes="pageSizes"
        :page-size="pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
      ></el-pagination>
</tmp>
