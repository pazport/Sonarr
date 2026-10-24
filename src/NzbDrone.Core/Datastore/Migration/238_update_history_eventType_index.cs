using FluentMigrator;
using NzbDrone.Core.Datastore.Migration.Framework;

namespace NzbDrone.Core.Datastore.Migration
{
    [Migration(238)]
    public class update_history_eventType_index : NzbDroneMigrationBase
    {
        protected override void MainDbUpgrade()
        {
            Delete.Index().OnTable("History").OnColumn("EventType");
            Create.Index().OnTable("History").OnColumn("EventType").Ascending()
                                             .OnColumn("Date").Descending();
        }
    }
}
