<template>
  <div id="app">
    <el-form ref="form" :model="form" :inline="true" label-width="80px">
      <el-form-item label="项目名称">
        <el-input v-model="form.name"></el-input>
      </el-form-item>
      <el-form-item label="区属">
        <el-select v-model="form.area" placeholder="全部">
          <el-option label="南山" value="南山"></el-option>
          <el-option label="福田" value="福田"></el-option>
          <el-option label="罗湖" value="罗湖"></el-option>
          <el-option label="宝安" value="宝安"></el-option>
          <el-option label="盐田" value="盐田"></el-option>
          <el-option label="龙岗" value="龙岗"></el-option>
          <el-option label="全部" value=""></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="类型">
        <el-select v-model="form.type" placeholder="全部">
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
          <el-option label="全部" value=""></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="房源编码">
        <el-input v-model="form.house_code"></el-input>
      </el-form-item>
      <el-form-item label="发布日期">
        <el-select v-model="form.release_date" placeholder="不限">
          <el-option label="一个月内" value="0"></el-option>
          <el-option label="三个月内" value="1"></el-option>
          <el-option label="半年内" value="2"></el-option>
          <el-option label="不限" value=""></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="form.state" placeholder="待售">
          <el-option label="待售" value="待售"></el-option>
          <el-option label="已售" value="已售"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSubmit">查询</el-button>
      </el-form-item>
    </el-form>
    <el-table :data="table_data" height="250" style="width: 100%">
      <el-table-column prop="xiangmumingchen" label="项目名称" width="180"></el-table-column>
      <el-table-column prop="hetongliushuihao" label="合同流水号" width="180"></el-table-column>
      <el-table-column prop="qushu" label="区属"></el-table-column>
      <el-table-column prop="mianji" label="面积(㎡)" width="180"></el-table-column>
      <el-table-column prop="yongtu" label="用途" width="180"></el-table-column>
      <el-table-column prop="louceng" label="楼层"></el-table-column>
      <el-table-column prop="fangyuanbianma" label="房源编码" width="180"></el-table-column>
      <el-table-column prop="jiage" label="价格" width="180"></el-table-column>
      <el-table-column prop="dailizhongjie" label="代理中介" width="180"></el-table-column>
      <el-table-column prop="faburiqi" label="发布日期"></el-table-column>
      <el-table-column prop="lianxidianhua" label="联系电话"></el-table-column>
      <el-table-column prop="zhuangtai" label="状态" width="180"></el-table-column>
      <el-table-column prop="shouchuriqi" label="售出日期" width="180"></el-table-column>
    </el-table>
    <el-pagination
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
      :current-page="currentPage"
      :page-sizes="[100, 200, 300, 400]"
      :page-size="100"
      layout="total, sizes, prev, pager, next, jumper"
      :total="400"
    ></el-pagination>
  </div>
</template>

<script>
export default {
  data() {
    return {
      form: {
        name: "",
        area: "",
        type: "",
        house_code: "",
        release_date: "",
        state: "待售"
      },
      table_data: [],
      currentPage: 2
    };
  },
  methods: {
    onSubmit() {
      console.log("submit!");
    },
    handleSizeChange(val) {
      console.log(`每页 ${val} 条`);
    },
    handleCurrentChange(val) {
      console.log(`当前页: ${val}`);
    }
  }
};
</script>
