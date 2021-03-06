Admin.StatsMapTableView = Ember.View.extend({
  tagName: 'table',

  classNames: ['table', 'table-striped', 'table-bordered', 'table-condensed'],

  didInsertElement: function() {
    this.$().dataTable({
      "bFilter": false,
      "aaSorting": [[1, "desc"]],
      "aaData": this.get('model.regions'),
      "aoColumns": [
        {
          mData: "name",
          sTitle: "Location",
          sDefaultContent: "-",
          mRender: _.bind(function(name, type, data) {
            if(type === 'display' && name && name !== '-') {
              var link;
              if(this.get('model.region_field') === 'request_ip_city') {
                var params = _.clone(this.get('controller.query.params'));
                params.search = 'request_ip_city:"' + data.id + '"';
                var link = '#/stats/logs/' + $.param(params);
              } else {
                var params = _.clone(this.get('controller.query.params'));
                params.region = data.id;
                var link = '#/stats/map/' + $.param(params);
              }

              return '<a href="' + link + '">' + _.escape(name) + '</a>';
            }

            return name;
          }, this),
        },
        {
          mData: "hits",
          sTitle: "Hits",
          sDefaultContent: "-",
          mRender: function(number, type) {
            if(type === 'display' && number && number !== '-') {
              return numeral(number).format('0,0')
            }

            return number;
          },
        },
      ]
    });
  },

  refreshData: function() {
    var table = this.$().dataTable();
    table.fnClearTable();
    table.fnAddData(this.get('model.regions'));
  }.observes('model.regions'),
});
