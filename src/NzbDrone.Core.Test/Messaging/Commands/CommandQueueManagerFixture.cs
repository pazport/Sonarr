using System;
using System.Collections.Generic;
using System.Linq;
using FluentAssertions;
using Moq;
using NUnit.Framework;
using NzbDrone.Core.Download;
using NzbDrone.Core.Lifecycle;
using NzbDrone.Core.Messaging.Commands;
using NzbDrone.Core.Test.Framework;
using NzbDrone.Test.Common;

namespace NzbDrone.Core.Test.Messaging.Commands
{
    [TestFixture]
    public class CommandQueueManagerFixture : CoreTest<CommandQueueManager>
    {
        [SetUp]
        public void Setup()
        {
            var id = 0;
            var commands = new List<CommandModel>();

            Mocker.GetMock<ICommandRepository>()
                  .Setup(s => s.Insert(It.IsAny<CommandModel>()))
                  .Returns<CommandModel>(c =>
                  {
                      c.Id = id + 1;
                      commands.Add(c);
                      id++;

                      return c;
                  });

            Mocker.GetMock<ICommandRepository>()
                  .Setup(s => s.Get(It.IsAny<int>()))
                  .Returns<int>(c =>
                  {
                      return commands.SingleOrDefault(e => e.Id == c);
                  });
        }

        [Test]
        public void should_not_remove_commands_for_five_minutes_after_they_end()
        {
            var command = Subject.Push<RefreshMonitoredDownloadsCommand>(new RefreshMonitoredDownloadsCommand());

            // Start the command to mimic CommandQueue's behaviour
            command.StartedAt = DateTime.Now;
            command.Status = CommandStatus.Started;

            Subject.Start(command);
            Subject.Complete(command, "All done");
            Subject.CleanCommands();

            Subject.Get(command.Id).Should().NotBeNull();

            Mocker.GetMock<ICommandRepository>()
                  .Verify(v => v.Get(It.IsAny<int>()), Times.Never());
        }

        [Test]
        public void should_log_error_when_command_has_been_running_longer_than_threshold()
        {
            var command = Subject.Push<ProcessMonitoredDownloadsCommand>(new ProcessMonitoredDownloadsCommand());

            command.StartedAt = DateTime.UtcNow.AddMinutes(-6);
            command.Status = CommandStatus.Started;

            Subject.CleanCommands();

            ExceptionVerification.ExpectedErrors(1);
        }

        [Test]
        public void should_not_log_error_when_command_has_been_running_shorter_than_threshold()
        {
            var command = Subject.Push<ProcessMonitoredDownloadsCommand>(new ProcessMonitoredDownloadsCommand());

            command.StartedAt = DateTime.UtcNow.AddMinutes(-4);
            command.Status = CommandStatus.Started;

            Subject.CleanCommands();

            ExceptionVerification.ExpectedErrors(0);
        }

        [Test]
        public void should_log_error_for_commands_orphaned_on_startup()
        {
            Mocker.GetMock<ICommandRepository>()
                  .Setup(s => s.Started())
                  .Returns(new List<CommandModel>
                  {
                      new CommandModel { Name = "ProcessMonitoredDownloads", Status = CommandStatus.Started }
                  });

            Mocker.GetMock<ICommandRepository>()
                  .Setup(s => s.Queued())
                  .Returns(new List<CommandModel>());

            Subject.Handle(new ApplicationStartedEvent());

            ExceptionVerification.ExpectedErrors(1);

            Mocker.GetMock<ICommandRepository>()
                  .Verify(v => v.OrphanStarted(), Times.Once());
        }
    }
}
