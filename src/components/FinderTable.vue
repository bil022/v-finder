<template>
  <b-container fluid>
    <!-- User Interface controls -->
    <b-row>
      <!--
      <b-col lg="6" class="my-1">
        <b-form-group
          label="Sort"
          label-for="sort-by-select"
          label-cols-sm="3"
          label-align-sm="right"
          label-size="sm"
          class="mb-0"
          v-slot="{ ariaDescribedby }"
        >
          <b-input-group size="sm">
            <b-form-select
              id="sort-by-select"
              v-model="sortBy"
              :options="sortOptions"
              :aria-describedby="ariaDescribedby"
              class="w-75"
            >
              <template #first>
                <option value="">-- none --</option>
              </template>
            </b-form-select>

            <b-form-select
              v-model="sortDesc"
              :disabled="!sortBy"
              :aria-describedby="ariaDescribedby"
              size="sm"
              class="w-25"
            >
              <option :value="false">Asc</option>
              <option :value="true">Desc</option>
            </b-form-select>
          </b-input-group>
        </b-form-group>
      </b-col>

      <b-col lg="6" class="my-1">
        <b-form-group
          label="Initial sort"
          label-for="initial-sort-select"
          label-cols-sm="3"
          label-align-sm="right"
          label-size="sm"
          class="mb-0"
        >
          <b-form-select
            id="initial-sort-select"
            v-model="sortDirection"
            :options="['asc', 'desc', 'last']"
            size="sm"
          ></b-form-select>
        </b-form-group>
      </b-col>
      -->
      <b-col lg="10" class="my-1">
        <b-form-group
          label="Search"
          label-for="filter-input"
          label-cols-sm="3"
          label-align-sm="right"
          label-size="sm"
          class="mb-0"
        >
          <b-input-group size="sm">
            <b-form-input
              id="filter-input"
              v-model="filter"
              type="search"
              placeholder="Type to Search"
              v-on:keyup.enter="updateItems()"
            ></b-form-input>

            <b-input-group-append>
              <b-button @click="updateItems()">Search</b-button>
            </b-input-group-append>
          </b-input-group>
        </b-form-group>
        Try: <b-link href="#" @click="filter='YX126';updateItems()">YX126</b-link> |
        <b-link href="#" @click="filter='/YX12[0-9]/';updateItems()">YX12[0-9]</b-link> |
        <b-link href="#" @click="filter='/naoki|yang/i';updateItems()">/naoki|yang/i</b-link>
        <b-form-group
          description="YX126: For YX126, /YX12[0-9]/: For YX120-129, /naoki|yang/i: For Naoki or Yang, case insensitive"
          label-cols-sm="3"
          label-align-sm="left"
          label-size="sm"
          class="mb-0"
        >
        </b-form-group>
      </b-col>

      <!--
      <b-col lg="6" class="my-1">
        <b-form-group
          v-model="sortDirection"
          label="Filter On"
          description="Leave all unchecked to filter on all data"
          label-cols-sm="3"
          label-align-sm="right"
          label-size="sm"
          class="mb-0"
          v-slot="{ ariaDescribedby }"
        >
          <b-form-checkbox-group
            v-model="filterOn"
            :aria-describedby="ariaDescribedby"
            class="mt-1"
          >
            <b-form-checkbox value="fcid">FCID</b-form-checkbox>
            <b-form-checkbox value="files">Files</b-form-checkbox>
            <b-form-checkbox value="path">Path</b-form-checkbox>
          </b-form-checkbox-group>
        </b-form-group>
      </b-col>
      -->
      <b-col sm="3" md="6" class="my-1">
        <b-form-group
          label="Per page"
          label-for="per-page-select"
          label-cols-sm="6"
          label-cols-md="4"
          label-cols-lg="3"
          label-align-sm="right"
          label-size="sm"
          class="mb-0"
        >
          <b-form-select
            id="per-page-select"
            v-model="perPage"
            :options="pageOptions"
            size="sm"
          ></b-form-select>
        </b-form-group>
      </b-col>

      <b-col sm="9" md="6" class="my-1">
        <b-pagination
          v-model="currentPage"
          :total-rows="totalRows"
          :per-page="perPage"
          align="fill"
          size="sm"
          class="my-0"
        ></b-pagination>
      </b-col>

    </b-row>

    <!-- Main table element -->
    <b-table
      :items="items"
      :fields="fields"
      :current-page="currentPage"
      :per-page="perPage"
      :sort-by.sync="sortBy"
      :sort-desc.sync="sortDesc"
      :sort-direction="sortDirection"
      stacked="md"
      show-empty
      small
      @filtered="onFiltered"
    >
      <template #cell(fcid)="row">
        {{ row.item.fcid }}
      </template>

      <template #cell(path)="row">
        <div class="text-left">{{ row.item.path }}</div>
      </template>

      <template #cell(actions)="row">
        <b-button size="sm" @click="row.toggleDetails" variant="outline-primary">
          {{ row.detailsShowing ? 'Hide' : 'Show' }} Files
        </b-button>

        <b-button size="sm" @click="info(row.item, row.index, $event.target)" class="mr-1">
          Metadata
        </b-button>
      </template>

      <template #row-details="row">
        <b-card>
          <b-table-simple>
          <b-tbody>
          <b-tr><b-th>File</b-th><b-th>Owner</b-th><b-th>Size</b-th></b-tr>
          <b-tr v-for="(value, key) in row.item.files" :key="key" class="text-left">
            <b-td>{{ value.file }}</b-td>
            <b-td>{{ value.owner }}</b-td>
            <b-td class="text-right">{{ numFormat(value.size) }}</b-td>
          </b-tr>
          </b-tbody>
          </b-table-simple>
        </b-card>
      </template>
    </b-table>

    <b-row>
      <b-col sm="3" md="6" class="my-1">
        <b-form-group
          label="Per page"
          label-for="per-page-select"
          label-cols-sm="6"
          label-cols-md="4"
          label-cols-lg="3"
          label-align-sm="right"
          label-size="sm"
          class="mb-0"
        >
          <b-form-select
            id="per-page-select"
            v-model="perPage"
            :options="pageOptions"
            size="sm"
          ></b-form-select>
        </b-form-group>
      </b-col>

      <b-col sm="9" md="6" class="my-1">
        <b-pagination
          v-model="currentPage"
          :total-rows="totalRows"
          :per-page="perPage"
          align="fill"
          size="sm"
          class="my-0"
        ></b-pagination>
      </b-col>
    </b-row>

    <!-- Info modal -->
    <b-modal :id="infoModal.id" :title="infoModal.title" ok-only @hide="resetInfoModal">
      <pre>{{ infoModal.content }}</pre>
    </b-modal>
  </b-container>
</template>

<script>
  import axios from 'axios';

  export default {
    data() {
      return {
        items: [ ],
        fields: [
          // fcid mdy path machine length drive hasSampleSheet hasDoc files
          { key: 'fcid', label: 'FCID', sortable: true, sortDirection: 'desc' },
          { key: 'mdy', label: 'Date', sortable: true, class: 'text-center' },
          { key: 'path', label: 'Path' },
          {
            key: 'machine',
            label: 'Sequencer',
            formatter: (value, key, item) => {
              switch (value) {
                case "@A00953": return "IGM";
                case "@VH00454": return "NextSeq";
                case "@NB501692": return "NextSeq";
                case "@K00168": return "HiSeq";
                case "@7001113": return "HiSeq";
                case "@HWI-ST216": return "HiSeq";
                case "@HWI-ST1113": return "HiSeq";
                case "@A00887": return "Berkeley";
                case "@A00742": return "Novogene";
              }
              return value
            },
            sortable: true,
            sortByFormatted: true,
            filterByFormatted: true
          },
          { key: 'length', label: 'Length' },
          { key: 'drive', label: 'Drive' }, 
          { key: 'actions', label: 'Actions' },
        ],
        totalRows: 1,
        currentPage: 1,
        perPage: 20,
        pageOptions: [20, 50, { value: 100, text: "Show a lot" }],
        sortBy: '',
        sortDesc: false,
        sortDirection: 'asc',
        filter: null,
        filterOn: ["fcid", "path", "files"],
        infoModal: {
          id: 'info-modal',
          title: '',
          content: ''
        }
      }
    },
    computed: {
      sortOptions() {
        console.log("sortOptions")
        // Create an options list from our fields
        return this.fields
          .filter(f => f.sortable)
          .map(f => {
            return { text: f.label, value: f.key }
          })
      }
    },
    mounted() {
      // console.log(process.env.NODE_ENV)
      // development or production
      // https://vuejs.org/v2/cookbook/using-axios-to-consume-apis.html
      this.updateItems()
    },
    methods: {
      updateItems() {
        var url='http://localhost/bli/v-finder/items.php';
        if (process.env.NODE_ENV=='production') {
          url='items.php';
        }
        console.log(url)
        //console.log(this)
        axios.get(url, {params: { search: this.filter }}).then(
          response => {
            console.log("Searching "+this.filter);
            console.log(response);
            this.items = response.data;
            this.totalRows = this.items.length

            for(const item of this.items) {
              this.$set(item, '_showDetails', this.filter!==null)
            }
          }
        )
        // Set the initial number of items
        this.totalRows = this.items.length
      },
      info(item, index, button) {
        console.log("info")
        this.infoModal.title = `Row: ${index+1}`
        this.infoModal.content = JSON.stringify(item, null, 2)
        this.$root.$emit('bv::show::modal', this.infoModal.id, button)
      },
      resetInfoModal() {
        console.log("resetInfoModal")
        this.infoModal.title = ''
        this.infoModal.content = ''
      },
      numFormat(amount) {
        if (amount !== '' || amount !== undefined || amount !== 0  || amount !== '0' || amount !== null) {
          return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        } else {
          return amount;
        }
      },
      onFiltered(filteredItems) {
        console.log("onFiltered")
        // Trigger pagination to update the number of buttons/pages due to filtering
        this.totalRows = filteredItems.length
        this.currentPage = 1
      }
    }
  }
</script>
