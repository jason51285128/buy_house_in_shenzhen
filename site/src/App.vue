<template>
  <div id="app">
    <el-form :model="form" label-position="left" size="mini" inline="true">
      <el-form-item label="项目名称">
        <el-input v-model="form.xiangmumingchen"></el-input>
      </el-form-item>
      <el-form-item label="区属">
        <el-select v-model="form.qushu" placeholder="全部">
          <el-option label="南山" value="南山"></el-option>
          <el-option label="福田" value="福田"></el-option>
          <el-option label="罗湖" value="罗湖"></el-option>
          <el-option label="宝安" value="宝安"></el-option>
          <el-option label="盐田" value="盐田"></el-option>
          <el-option label="龙岗" value="龙岗"></el-option>
          <el-option label="全部" value></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="类型">
        <el-select v-model="form.leixing" placeholder="全部">
          <el-option label="产业研发用房" value="研发"></el-option>
          <el-option label="仓储" value="仓储"></el-option>
          <el-option label="住宅" value="住宅"></el-option>
          <el-option label="公寓" value="公寓"></el-option>
          <el-option label="写字楼" value="写字楼"></el-option>
          <el-option label="别墅" value="别墅"></el-option>
          <el-option label="办公" value="办公"></el-option>
          <el-option label="宿舍" value="宿舍"></el-option>
          <el-option label="居住" value="居住"></el-option>
          <el-option label="厂房" value="办公"></el-option>
          <el-option label="商业" value="商"></el-option>
          <el-option label="工业" value="工业"></el-option>
          <el-option label="文化活动用房" value="文化活动用房"></el-option>
          <el-option label="综合楼" value="综合楼"></el-option>
          <el-option label="食堂" value="食堂"></el-option>
          <el-option label="酒店" value="酒店"></el-option>
          <el-option label="其他" value="其他"></el-option>
          <el-option label="全部" value></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="价格（万）">
        <el-input v-model="form.jiagel" placeholder="最低"></el-input>
      </el-form-item>
      <el-form-item label="-"></el-form-item>
      <el-form-item>
        <el-input v-model="form.jiageh" placeholder="最高"></el-input>
      </el-form-item>
      <el-form-item label="房源编码">
        <el-input v-model="form.fangyuanbianma"></el-input>
      </el-form-item>
      <el-form-item label="发布日期">
        <el-select v-model="form.faburiqi" placeholder="不限">
          <el-option label="一个月内" value="30"></el-option>
          <el-option label="三个月内" value="90"></el-option>
          <el-option label="半年内" value="180"></el-option>
          <el-option label="不限" value></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="form.zhuangtai" placeholder="待售">
          <el-option label="在售" value="在售"></el-option>
          <el-option label="已售" value="已售"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSubmit" v-loading.fullscreen.lock="loading">查询</el-button>
      </el-form-item>
    </el-form>
    <el-table :data="tableData" style="width: 100%">
      <el-table-column prop="xiangmumingchen" label="项目名称"></el-table-column>
      <el-table-column prop="hetongliushuihao" label="合同流水号"></el-table-column>
      <el-table-column prop="qushu" label="区属"></el-table-column>
      <el-table-column prop="mianjipingfangmi" label="面积(㎡)"></el-table-column>
      <el-table-column prop="yongtu" label="用途"></el-table-column>
      <el-table-column prop="louceng" label="楼层"></el-table-column>
      <el-table-column prop="fangyuanbianma" label="房源编码"></el-table-column>
      <el-table-column prop="jiagewan" label="价格"></el-table-column>
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
  </div>
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
        fangyuanbianma: "",
        faburiqi: "",
        zhuangtai: "在售"
      },
      loading: false,
      originData: [],
      tableData: [],
      currentPage: 1,
      pageSize: 20,
      pageSizes: [20, 50, 100, 200],
      total: 0,
      dataUrl: "http://192.168.126.221:8080"
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
        this.currentPage * this.pageSizes
      );
    }
  }
};
</script>
